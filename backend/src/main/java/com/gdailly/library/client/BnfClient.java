package com.gdailly.library.client;

import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.gdailly.library.config.LivreProperties;
import com.gdailly.library.util.Isbn;

/**
 * Catalogue of the Bibliothèque nationale de France, SRU API in UNIMARC: the most complete source for books
 * published in France. Older records only carry the ISBN-10, so both forms are searched.
 */
@Component
public class BnfClient implements MetadataClient {

    private static final String ANY_NAMESPACE = "*";
    private static final Pattern PAGES = Pattern.compile("(\\d+)\\s*p(?:\\.|\\b)");
    /** Non-sorting markers (NSB/NSE) and their older variants, around leading articles: "\u0098Le \u009CPetit Prince". */
    private static final Pattern NON_SORTING = Pattern.compile("[\\u0088\\u0089\\u0098\\u009C]");
    /** MARC bibliographic codes that differ from the ISO 639-2/T codes known to {@link java.util.Locale}. */
    private static final Map<String, String> BIBLIOGRAPHIC_LANGUAGES = Map.ofEntries(
            Map.entry("fre", "fr"), Map.entry("ger", "de"), Map.entry("dut", "nl"), Map.entry("chi", "zh"),
            Map.entry("gre", "el"), Map.entry("cze", "cs"), Map.entry("per", "fa"), Map.entry("rum", "ro"),
            Map.entry("wel", "cy"), Map.entry("arm", "hy"), Map.entry("baq", "eu"), Map.entry("bur", "my"),
            Map.entry("geo", "ka"), Map.entry("ice", "is"), Map.entry("mac", "mk"), Map.entry("mao", "mi"),
            Map.entry("may", "ms"), Map.entry("alb", "sq"), Map.entry("slo", "sk"), Map.entry("tib", "bo"));

    /** Records read per request when listing a series, and at most in all. */
    static final int SERIES_PAGE = 100;
    static final int MAX_SERIES_RECORDS = 500;

    private final RestClient http;

    BnfClient(LivreProperties properties) {
        this.http = HttpClients.restClient(properties.isbn().bnfUrl(), properties.isbn().timeout());
    }

    @Override
    public Optional<String> fetch(String isbn13) {
        // Read as bytes: the catalogue answers in UTF-8, whatever charset its Content-Type announces (if any).
        byte[] bytes = http.get()
                .uri(uri -> uri.path("/api/SRU")
                        .queryParam("version", "1.2")
                        .queryParam("operation", "searchRetrieve")
                        .queryParam("recordSchema", "unimarcxchange")
                        .queryParam("maximumRecords", "1")
                        .queryParam("query", "{query}")
                        .build(query(isbn13)))
                .accept(MediaType.APPLICATION_XML, MediaType.TEXT_XML)
                .retrieve()
                .body(byte[].class);
        String body = bytes == null ? null : new String(bytes, StandardCharsets.UTF_8);
        return parse(isbn13, body).isPresent() ? Optional.of(body) : Optional.empty();
    }

    /**
     * Books of a series, from the identifier of its BnF record (zone 461 $0 of a volume): multivolume sets (ensembles)
     * first, else editorial collections. Several printings of a volume can be listed. Throws on network errors.
     */
    public List<SeriesVolume> fetchSeriesVolumes(String seriesRef) {
        List<SeriesVolume> volumes = fetchLinked("bib.ens2bib", seriesRef);
        return volumes.isEmpty() ? fetchLinked("bib.col2bib", seriesRef) : volumes;
    }

    private List<SeriesVolume> fetchLinked(String index, String seriesRef) {
        List<SeriesVolume> volumes = new ArrayList<>();
        for (int start = 1; start <= MAX_SERIES_RECORDS; start += SERIES_PAGE) {
            int first = start;
            byte[] bytes = http.get()
                    .uri(uri -> uri.path("/api/SRU")
                            .queryParam("version", "1.2")
                            .queryParam("operation", "searchRetrieve")
                            .queryParam("recordSchema", "unimarcxchange")
                            .queryParam("maximumRecords", String.valueOf(SERIES_PAGE))
                            .queryParam("startRecord", String.valueOf(first))
                            .queryParam("query", "{query}")
                            .build(index + " all \"" + seriesRef + "\""))
                    .accept(MediaType.APPLICATION_XML, MediaType.TEXT_XML)
                    .retrieve()
                    .body(byte[].class);
            List<SeriesVolume> page = bytes == null ? List.of()
                    : parseSeriesVolumes(new String(bytes, StandardCharsets.UTF_8), seriesRef);
            volumes.addAll(page);
            if (records(bytes) < SERIES_PAGE) {
                break;
            }
        }
        return volumes;
    }

    private static int records(byte[] bytes) {
        if (bytes == null) {
            return 0;
        }
        return unimarcRecords(read(new String(bytes, StandardCharsets.UTF_8))).size();
    }

    /** One book of a series: its volume number (null when the record gives none), title, ISBN and year. */
    public record SeriesVolume(Integer number, String title, String isbn13, Integer year) {
    }

    /** The volumes listed in an SRU answer; {@code seriesRef} picks the right 461 field when a book is in several. */
    static List<SeriesVolume> parseSeriesVolumes(String payload, String seriesRef) {
        List<SeriesVolume> volumes = new ArrayList<>();
        for (Element element : unimarcRecords(read(payload))) {
            Unimarc record = new Unimarc(element);
            String title = record.first("200", "a");
            if (title == null) {
                continue;
            }
            String publication = record.has("210") ? "210" : "214";
            String isbn = record.first("010", "a");
            volumes.add(new SeriesVolume(
                    volumeNumber(record, seriesRef),
                    title,
                    isbn == null ? null : Isbn.toIsbn13(isbn).orElse(null),
                    BookMetadata.parseYear(record.first(publication, "d"))));
        }
        return volumes;
    }

    private static Integer volumeNumber(Unimarc record, String seriesRef) {
        for (Element field : record.fields("461")) {
            if (seriesRef.equals(Unimarc.subfield(field, "0"))) {
                return BookMetadata.parseSeriesNumber(Unimarc.subfield(field, "v"));
            }
        }
        return BookMetadata.parseSeriesNumber(record.first("225", "v"));
    }

    /** Identifier of the series record a book belongs to (zone 461 $0), from a cached BnF answer; null if none. */
    public static String seriesRef(String payload) {
        if (payload == null || payload.isBlank()) {
            return null;
        }
        for (Element element : unimarcRecords(read(payload))) {
            String ref = new Unimarc(element).first("461", "0");
            if (ref != null && ref.matches("\\d{6,12}")) {
                return ref;
            }
        }
        return null;
    }

    /** The UNIMARC records of an SRU answer (the envelope also has {@code <srw:record>} elements). */
    private static List<Element> unimarcRecords(Document document) {
        List<Element> records = new ArrayList<>();
        NodeList nodes = document.getElementsByTagNameNS(ANY_NAMESPACE, "record");
        for (int i = 0; i < nodes.getLength(); i++) {
            Element record = (Element) nodes.item(i);
            // The innermost record: <srw:record> wraps the UNIMARC <record> holding the datafields.
            if (record.getElementsByTagNameNS(ANY_NAMESPACE, "datafield").getLength() > 0
                    && record.getElementsByTagNameNS(ANY_NAMESPACE, "record").getLength() == 0) {
                records.add(record);
            }
        }
        return records;
    }

    static String query(String isbn13) {
        String query = "bib.isbn all \"" + isbn13 + "\"";
        return Isbn.toIsbn10(isbn13).map(isbn10 -> query + " or bib.isbn all \"" + isbn10 + "\"").orElse(query);
    }

    @Override
    public Optional<BookMetadata> parse(String isbn13, String payload) {
        if (payload == null || payload.isBlank()) {
            return Optional.empty();
        }
        NodeList records = read(payload).getElementsByTagNameNS(ANY_NAMESPACE, "record");
        for (int i = 0; i < records.getLength(); i++) {
            Element record = (Element) records.item(i);
            // The SRU envelope also has <srw:record> elements: the UNIMARC record is the one holding datafields.
            if (record.getElementsByTagNameNS(ANY_NAMESPACE, "datafield").getLength() > 0) {
                return toMetadata(new Unimarc(record));
            }
        }
        return Optional.empty();
    }

    private static Optional<BookMetadata> toMetadata(Unimarc record) {
        String title = record.first("200", "a");
        if (title == null) {
            return Optional.empty();
        }
        String publication = record.has("210") ? "210" : "214";
        return Optional.of(new BookMetadata(
                title,
                record.first("200", "e"),
                authors(record),
                OpenLibraryClient.publisher(record.first(publication, "c")),
                BookMetadata.parseYear(record.first(publication, "d")),
                pages(record.first("215", "a")),
                language(record.first("101", "a")),
                record.first("330", "a"),
                null,
                series(record),
                seriesNumber(record)));
    }

    /** Series statement (225), else the link to the series record (461). */
    private static String series(Unimarc record) {
        String series = BookMetadata.seriesTitle(record.first("225", "a"));
        return series != null ? series : BookMetadata.seriesTitle(record.first("461", "t"));
    }

    /** Volume number of the field the series came from. */
    private static Integer seriesNumber(Unimarc record) {
        if (record.first("225", "a") != null) {
            return BookMetadata.parseSeriesNumber(record.first("225", "v"));
        }
        return BookMetadata.parseSeriesNumber(record.first("461", "v"));
    }

    /** Main and co-authors ("Albert Camus"), else the statement of responsibility of the title. */
    private static String authors(Unimarc record) {
        List<String> names = new ArrayList<>();
        for (String tag : new String[] {"700", "701"}) {
            for (Element field : record.fields(tag)) {
                String role = Unimarc.subfield(field, "4");
                String surname = Unimarc.subfield(field, "a");
                if (surname == null || (role != null && !role.equals("070") && !role.equals("0070"))) {
                    continue;
                }
                String forename = Unimarc.subfield(field, "b");
                names.add(forename == null ? surname : forename + " " + surname);
            }
        }
        if (!names.isEmpty()) {
            return String.join(", ", names);
        }
        String responsibility = record.first("200", "f");
        return responsibility == null ? null : BookMetadata.text(responsibility.split(";")[0]);
    }

    static Integer pages(String extent) {
        if (extent == null) {
            return null;
        }
        Matcher matcher = PAGES.matcher(extent);
        Integer largest = null;
        while (matcher.find()) {
            int value = Integer.parseInt(matcher.group(1));
            largest = largest == null ? value : Math.max(largest, value);
        }
        return largest != null && largest > 0 ? largest : null;
    }

    /** "fre" → "fr", like the codes given by Google Books. */
    static String language(String code) {
        if (code == null) {
            return null;
        }
        String lower = code.toLowerCase(java.util.Locale.ROOT);
        String bibliographic = BIBLIOGRAPHIC_LANGUAGES.get(lower);
        if (bibliographic != null) {
            return bibliographic;
        }
        for (String iso2 : java.util.Locale.getISOLanguages()) {
            if (java.util.Locale.of(iso2).getISO3Language().equals(lower)) {
                return iso2;
            }
        }
        return null;
    }

    private static Document read(String xml) {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setNamespaceAware(true);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setExpandEntityReferences(false);
            DocumentBuilder builder = factory.newDocumentBuilder();
            return builder.parse(new InputSource(new StringReader(xml)));
        } catch (ParserConfigurationException | SAXException | IOException e) {
            throw new IllegalArgumentException("Unreadable BnF answer", e);
        }
    }

    /** Fields of a UNIMARC record in MARCXchange. */
    private record Unimarc(Element record) {

        List<Element> fields(String tag) {
            List<Element> fields = new ArrayList<>();
            NodeList nodes = record.getElementsByTagNameNS(ANY_NAMESPACE, "datafield");
            for (int i = 0; i < nodes.getLength(); i++) {
                Element field = (Element) nodes.item(i);
                if (tag.equals(field.getAttribute("tag"))) {
                    fields.add(field);
                }
            }
            return fields;
        }

        boolean has(String tag) {
            return !fields(tag).isEmpty();
        }

        String first(String tag, String code) {
            for (Element field : fields(tag)) {
                String value = subfield(field, code);
                if (value != null) {
                    return value;
                }
            }
            return null;
        }

        static String subfield(Element field, String code) {
            NodeList nodes = field.getElementsByTagNameNS(ANY_NAMESPACE, "subfield");
            for (int i = 0; i < nodes.getLength(); i++) {
                Element subfield = (Element) nodes.item(i);
                if (code.equals(subfield.getAttribute("code"))) {
                    String text = BookMetadata.text(NON_SORTING.matcher(subfield.getTextContent()).replaceAll(""));
                    if (text != null) {
                        return text;
                    }
                }
            }
            return null;
        }
    }
}
