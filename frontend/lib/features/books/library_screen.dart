import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../../shared/search_field.dart';
import 'book_cover.dart';
import 'books_providers.dart';
import 'reading_labels.dart';

/// Mock-up 2 · Bibliothèque: search, status filters, grid or list of covers.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(libraryQueryProvider);
    final books = ref.watch(booksProvider(query));
    final grid = ref.watch(gridViewProvider);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ma bibliothèque', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 2),
                          Text(
                            books.hasValue ? _count(books.requireValue.totalItems) : ' ',
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _ViewToggle(grid: grid, onChanged: ref.read(gridViewProvider.notifier).set),
                  ],
                ),
                const SizedBox(height: 14),
                SearchField(onChanged: ref.read(libraryQueryProvider.notifier).search),
                const SizedBox(height: 14),
                _StatusChips(
                  selected: query.status,
                  onSelected: ref.read(libraryQueryProvider.notifier).filterStatus,
                ),
              ],
            ),
          ),
        ),
        ...switch (books) {
          AsyncValue(:final value?) when value.items.isEmpty => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    query.text.isEmpty && query.status == null ? 'Aucun livre pour l\'instant.' : 'Aucun livre trouvé.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          AsyncValue(:final value?) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: grid ? _BookGrid(books: value.items) : _BookList(books: value.items),
              ),
            ],
          AsyncValue(:final error?) => [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(booksProvider(query))),
                ),
              ),
            ],
          _ => [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
        },
      ],
    );
  }

  static String _count(int total) => total <= 1 ? '$total livre' : '$total livres';
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.grid, required this.onChanged});

  final bool grid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: true, icon: Icon(Icons.grid_view_outlined), tooltip: 'Grille'),
        ButtonSegment(value: false, icon: Icon(Icons.view_list_outlined), tooltip: 'Liste'),
      ],
      selected: {grid},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.selected, required this.onSelected});

  final ReadingStatus? selected;
  final ValueChanged<ReadingStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(ReadingStatus?, String)>[
      (null, 'Tous'),
      (ReadingStatus.TO_READ, 'À lire'),
      (ReadingStatus.READING, 'En cours'),
      (ReadingStatus.READ, 'Lu'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (status, label) in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: selected == status,
                showCheckmark: false,
                labelStyle: TextStyle(color: selected == status ? Colors.white : AppColors.text),
                onSelected: (_) => onSelected(status),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.books});

  final List<BookResponse> books;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.46,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return InkWell(
          onTap: () => context.push('/books/${book.id}'),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(title: book.title, authors: book.authors, imageUrl: book.cover?.thumbUrl),
              const SizedBox(height: 6),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.25),
              ),
              Text(
                readingSummary(book.myReading),
                maxLines: 1,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});

  final List<BookResponse> books;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: books.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = books[index];
        final summary = readingSummary(book.myReading);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: BookCover(
            title: book.title,
            imageUrl: book.cover?.thumbUrl,
            width: 44,
            showText: false,
          ),
          title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            [if (book.authors != null) book.authors!, if (summary.isNotEmpty) summary].join('\n'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          onTap: () => context.push('/books/${book.id}'),
        );
      },
    );
  }
}
