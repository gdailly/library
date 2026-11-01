import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import 'metadata_labels.dart';

/// Filters of the comparison list.
typedef MetadataBooksQuery = ({String q, bool onlyDifferences, int page});

final metadataBooksProvider =
    FutureProvider.autoDispose.family<PageResponseBookMetadataSummary, MetadataBooksQuery>((ref, query) async {
  final response = await ref.watch(libraryApiProvider).getAdminApi().listBookMetadata(
        q: query.q.isEmpty ? null : query.q,
        onlyDifferences: query.onlyDifferences,
        page: query.page,
      );
  return response.data!;
});

/// Administration · the books with an ISBN and how their sources compare with what the library holds.
class MetadataBooksScreen extends ConsumerStatefulWidget {
  const MetadataBooksScreen({super.key});

  @override
  ConsumerState<MetadataBooksScreen> createState() => _MetadataBooksScreenState();
}

class _MetadataBooksScreenState extends ConsumerState<MetadataBooksScreen> {
  final _search = TextEditingController();
  MetadataBooksQuery _query = (q: '', onlyDifferences: true, page: 0);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(metadataBooksProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Comparer les sources')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Titre ou auteur',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onSubmitted: (text) => setState(() => _query = (q: text.trim(), onlyDifferences: _query.onlyDifferences, page: 0)),
                ),
              ),
              SwitchListTile(
                title: const Text('Seulement les livres avec des différences'),
                value: _query.onlyDifferences,
                onChanged: (value) => setState(() => _query = (q: _query.q, onlyDifferences: value, page: 0)),
              ),
              Expanded(
                child: switch (books) {
                  AsyncValue(:final value?) => _list(value),
                  AsyncValue(:final error?) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: MessageBox.error(
                        errorMessage(error),
                        onRetry: () => ref.invalidate(metadataBooksProvider(_query)),
                      ),
                    ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(PageResponseBookMetadataSummary page) {
    if (page.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _query.onlyDifferences ? 'Aucune différence entre les livres et les sources.' : 'Aucun livre avec un ISBN.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '${page.totalItems} livre${page.totalItems > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        for (final book in page.items) _BookLine(book: book),
        if (page.totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Page précédente',
                onPressed: page.page == 0 ? null : () => _goTo(page.page - 1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${page.page + 1} / ${page.totalPages}'),
              IconButton(
                tooltip: 'Page suivante',
                onPressed: page.page + 1 >= page.totalPages ? null : () => _goTo(page.page + 1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
      ],
    );
  }

  void _goTo(int page) => setState(() => _query = (q: _query.q, onlyDifferences: _query.onlyDifferences, page: page));
}

class _BookLine extends ConsumerWidget {
  const _BookLine({required this.book});

  final BookMetadataSummary book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = book.fetchedAt == null
        ? 'Jamais recherché'
        : book.notFound
            ? 'Inconnu des sources'
            : book.sources.map(sourceLabel).join(' · ');
    final differences = book.differences.map((f) => metadataFields[f] ?? f).join(', ');
    return ListTile(
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [if (book.authors != null) book.authors!, status, if (differences.isNotEmpty) 'Diffère : $differences'].join('\n'),
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      isThreeLine: true,
      trailing: book.differences.isEmpty
          ? const Icon(Icons.check_circle_outline, color: AppColors.accent)
          : Badge(
              label: Text('${book.differences.length}'),
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.compare_arrows),
            ),
      onTap: () async {
        await context.push('/admin/books/${book.id}');
        ref.invalidate(metadataBooksProvider);
      },
    );
  }
}
