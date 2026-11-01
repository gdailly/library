package com.gdailly.library.business;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.gdailly.library.client.BookMetadata;
import com.gdailly.library.dto.ApplyMetadataRequest;
import com.gdailly.library.dto.BookMetadataResponse;
import com.gdailly.library.dto.BookMetadataSummary;
import com.gdailly.library.dto.MetadataSource;
import com.gdailly.library.dto.PageResponse;
import com.gdailly.library.dto.SourceMetadataResponse;
import com.gdailly.library.dto.SyncMode;
import com.gdailly.library.entity.Book;
import com.gdailly.library.entity.IsbnLookup;
import com.gdailly.library.entity.LookupSource;
import com.gdailly.library.exception.BadRequestException;
import com.gdailly.library.exception.ConflictException;
import com.gdailly.library.exception.NotFoundException;
import com.gdailly.library.exception.ServiceUnavailableException;
import com.gdailly.library.mapper.IsbnLookupMapper;
import com.gdailly.library.repository.BookRepository;
import com.gdailly.library.repository.IsbnLookupRepository;
import com.gdailly.library.security.CurrentUser;
import com.gdailly.library.util.Strings;

/**
 * Administrator's view of the metadata, book by book: the book beside what each source says about its ISBN
 * (from the cache, no API call), and copying chosen fields of one source into the book.
 */
@Service
public class MetadataInspectionService {

    static final int PAGE_SIZE = 50;
    static final Set<String> FIELD_NAMES =
            Set.of("title", "subtitle", "authors", "publisher", "year", "pages", "language", "summary", "cover");

    /** A book field and the same information in a source's answer. */
    private record Field(String name, Function<Book, Object> ofBook, Function<BookMetadata, Object> ofSource) {
    }

    private static final List<Field> COMPARED = List.of(
            new Field("title", Book::getTitle, BookMetadata::title),
            new Field("subtitle", Book::getSubtitle, BookMetadata::subtitle),
            new Field("authors", Book::getAuthors, BookMetadata::authors),
            new Field("publisher", Book::getPublisher, BookMetadata::publisher),
            new Field("year", Book::getYear, BookMetadata::year),
            new Field("pages", Book::getPages, BookMetadata::pages),
            new Field("language", Book::getLanguage, BookMetadata::language),
            new Field("summary", Book::getSummary, BookMetadata::summary));

    private final BookRepository books;
    private final IsbnLookupRepository isbnCache;
    private final MetadataSources sources;
    private final CoverService covers;
    private final BookService bookService;
    private final IsbnLookupMapper mapper;
    private final TransactionTemplate transaction;

    MetadataInspectionService(BookRepository books, IsbnLookupRepository isbnCache, MetadataSources sources,
            CoverService covers, BookService bookService, IsbnLookupMapper mapper,
            PlatformTransactionManager transactionManager) {
        this.books = books;
        this.isbnCache = isbnCache;
        this.sources = sources;
        this.covers = covers;
        this.bookService = bookService;
        this.mapper = mapper;
        this.transaction = new TransactionTemplate(transactionManager);
    }

    /** Books with an ISBN, by title; {@code q} searches title and authors; {@code onlyDifferences} keeps the disputed ones. */
    @Transactional(readOnly = true)
    public PageResponse<BookMetadataSummary> list(CurrentUser user, String q, boolean onlyDifferences, int page) {
        MetadataSyncService.requireAdmin(user);
        String text = Strings.trimToNull(q) == null ? null : normalise(q);
        List<Book> candidates = books.findByLibraryIdAndIsbn13IsNotNull(user.libraryId(), Sort.by("title", "id")).stream()
                .filter(book -> text == null || normalise(book.getTitle()).contains(text)
                        || (book.getAuthors() != null && normalise(book.getAuthors()).contains(text)))
                .toList();
        Map<String, IsbnLookup> entries = isbnCache.findAllById(candidates.stream().map(Book::getIsbn13).toList())
                .stream().collect(Collectors.toMap(IsbnLookup::getIsbn13, Function.identity()));
        List<BookMetadataSummary> summaries = candidates.stream()
                .map(book -> summary(book, entries.get(book.getIsbn13())))
                .filter(summary -> !onlyDifferences || !summary.differences().isEmpty())
                .toList();
        int current = Math.max(page, 0);
        int from = Math.min(current * PAGE_SIZE, summaries.size());
        int to = Math.min(from + PAGE_SIZE, summaries.size());
        int totalPages = (summaries.size() + PAGE_SIZE - 1) / PAGE_SIZE;
        return new PageResponse<>(summaries.subList(from, to), current, PAGE_SIZE, summaries.size(), totalPages);
    }

    @Transactional(readOnly = true)
    public BookMetadataResponse get(CurrentUser user, Long bookId) {
        MetadataSyncService.requireAdmin(user);
        Book book = books.findByIdAndLibraryId(bookId, user.libraryId()).orElseThrow(NotFoundException::new);
        IsbnLookup entry = book.getIsbn13() == null ? null : isbnCache.findById(book.getIsbn13()).orElse(null);
        Map<LookupSource, BookMetadata> answers = entry == null ? Map.of() : sources.decode(entry);
        List<SourceMetadataResponse> bySource = MetadataSources.ALL.stream()
                .filter(answers::containsKey)
                .map(source -> mapper.toSourceMetadata(MetadataSource.valueOf(source.name()), answers.get(source)))
                .toList();
        SourceMetadataResponse merged = MetadataMerger.merge(answers)
                .map(m -> mapper.toSourceMetadata(null, m.metadata()))
                .orElse(null);
        return new BookMetadataResponse(bookService.get(user, bookId), entry == null ? null : entry.getFetchedAt(),
                entry != null && entry.getSource() == LookupSource.NOT_FOUND, bySource, merged,
                differences(book, answers));
    }

    /** Copies the chosen fields of one source's stored answer into the book, even over values already set. */
    public BookMetadataResponse apply(CurrentUser user, Long bookId, ApplyMetadataRequest request) {
        MetadataSyncService.requireAdmin(user);
        if (request.source() == MetadataSource.LIBRARY) {
            throw new BadRequestException("Choisis une source externe.");
        }
        if (!FIELD_NAMES.containsAll(request.fields())) {
            throw new BadRequestException("Champ inconnu.");
        }
        LookupSource source = LookupSource.valueOf(request.source().name());
        BookMetadata answer = transaction.execute(status -> {
            Book book = books.findByIdAndLibraryId(bookId, user.libraryId()).orElseThrow(NotFoundException::new);
            if (book.getIsbn13() == null) {
                throw new BadRequestException("Ce livre n'a pas d'ISBN.");
            }
            BookMetadata found = isbnCache.findById(book.getIsbn13()).map(sources::decode).orElse(Map.of()).get(source);
            if (found == null) {
                throw new ConflictException("Cette source n'a pas de données pour ce livre : récupère-les d'abord.");
            }
            return found;
        });
        String coverKey = null;
        if (request.fields().contains("cover")) {
            if (answer.coverUrl() == null) {
                throw new ConflictException("Cette source n'a pas de couverture pour ce livre.");
            }
            coverKey = covers.importFromUrl(answer.coverUrl()).orElseThrow(
                    () -> new ServiceUnavailableException("La couverture de cette source n'a pas pu être téléchargée."));
        }
        String cover = coverKey;
        transaction.executeWithoutResult(status -> {
            Book book = books.findByIdAndLibraryId(bookId, user.libraryId()).orElseThrow(NotFoundException::new);
            MetadataSyncService.apply(book, answer, cover, SyncMode.REPLACE, Set.copyOf(request.fields()));
        });
        return get(user, bookId);
    }

    private BookMetadataSummary summary(Book book, IsbnLookup entry) {
        Map<LookupSource, BookMetadata> answers = entry == null ? Map.of() : sources.decode(entry);
        List<MetadataSource> known = MetadataSources.ALL.stream()
                .filter(answers::containsKey)
                .map(source -> MetadataSource.valueOf(source.name()))
                .toList();
        return new BookMetadataSummary(book.getId(), book.getTitle(), book.getAuthors(), book.getIsbn13(),
                book.getCoverKey() != null, known, entry == null ? null : entry.getFetchedAt(),
                entry != null && entry.getSource() == LookupSource.NOT_FOUND, differences(book, answers));
    }

    /** Fields where a source knows a value that is not the book's; "cover" when the book has none but a source has. */
    static List<String> differences(Book book, Map<LookupSource, BookMetadata> answers) {
        List<String> differences = new ArrayList<>();
        for (Field field : COMPARED) {
            Object current = field.ofBook().apply(book);
            boolean disputed = answers.values().stream()
                    .map(field.ofSource())
                    .filter(Objects::nonNull)
                    .anyMatch(value -> !same(current, value));
            if (disputed) {
                differences.add(field.name());
            }
        }
        if (book.getCoverKey() == null && answers.values().stream().anyMatch(a -> a.coverUrl() != null)) {
            differences.add("cover");
        }
        return differences;
    }

    /** Equal, ignoring case, accents, typographic apostrophes and repeated spaces. */
    static boolean same(Object current, Object value) {
        if (current instanceof String a && value instanceof String b) {
            return normalise(a).equals(normalise(b));
        }
        return Objects.equals(current, value);
    }

    private static String normalise(String text) {
        String folded = Normalizer.normalize(text, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
        return folded.replace('’', '\'').replaceAll("\\s+", " ").trim().toLowerCase(Locale.ROOT);
    }
}
