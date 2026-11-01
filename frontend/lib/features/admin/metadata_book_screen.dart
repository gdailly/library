import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../books/book_cover.dart';
import '../books/books_providers.dart';
import 'book_sync_dialog.dart';
import 'metadata_labels.dart';

final bookMetadataProvider = FutureProvider.autoDispose.family<BookMetadataResponse, int>((ref, id) async {
  final response = await ref.watch(libraryApiProvider).getAdminApi().getBookMetadata(id: id);
  return response.data!;
});

/// Administration · one book beside each source, field by field. A source's value can be copied into the book,
/// and each source can be queried again.
class MetadataBookScreen extends ConsumerStatefulWidget {
  const MetadataBookScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<MetadataBookScreen> createState() => _MetadataBookScreenState();
}

class _MetadataBookScreenState extends ConsumerState<MetadataBookScreen> {
  bool _busy = false;

  AdminApi get _api => ref.read(libraryApiProvider).getAdminApi();

  /// Runs an action, then reloads this book everywhere; [done] describes the result in a snack bar.
  Future<void> _run(Future<String> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final done = await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
    } finally {
      ref
        ..invalidate(bookMetadataProvider(widget.bookId))
        ..invalidate(bookProvider(widget.bookId))
        ..invalidate(booksProvider);
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _sync(SyncMode mode, {MetadataSource? source}) => _run(() async {
        final result = (await _api.syncBookMetadata(id: widget.bookId, mode: mode, source_: source)).data!;
        if (mode == SyncMode.FETCH) {
          return result.outcome == SyncOutcome.NOT_FOUND
              ? '${source == null ? 'Aucune source' : sourceLabel(source)} ne connaît pas cet ISBN.'
              : 'Données de ${source == null ? 'toutes les sources' : sourceLabel(source)} récupérées.';
        }
        return syncSummary(result);
      });

  Future<void> _apply(MetadataSource source, List<String> fields) => _run(() async {
        await _api.applyBookMetadata(
          id: widget.bookId,
          applyMetadataRequest: ApplyMetadataRequest(source_: source, fields: fields),
        );
        final names = fields.map((f) => metadataFields[f]?.toLowerCase() ?? f).join(', ');
        return 'Repris de ${sourceLabel(source)} : $names.';
      });

  @override
  Widget build(BuildContext context) {
    final metadata = ref.watch(bookMetadataProvider(widget.bookId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sources du livre'),
        bottom: _busy ? const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()) : null,
      ),
      body: switch (metadata) {
        AsyncValue(:final value?) => _content(value),
        AsyncValue(:final error?) => Padding(
            padding: const EdgeInsets.all(16),
            child: MessageBox.error(
              errorMessage(error),
              onRetry: () => ref.invalidate(bookMetadataProvider(widget.bookId)),
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BookMetadataResponse data) {
    final book = data.book;
    final known = {for (final answer in data.sources) answer.source_!: answer};
    final status = data.fetchedAt == null
        ? 'Cet ISBN n\'a jamais été recherché.'
        : data.notFound
            ? 'Aucune source ne connaissait cet ISBN le ${shortDate(data.fetchedAt!)}.'
            : 'Données des sources du ${shortDate(data.fetchedAt!)}.';
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              ['ISBN ${book.isbn13 ?? '—'}', status].join(' · '),
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : () => _sync(SyncMode.FETCH),
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Tout récupérer'),
                ),
                for (final source in externalSources)
                  OutlinedButton(
                    onPressed: _busy ? null : () => _sync(SyncMode.FETCH, source: source),
                    child: Text('Récupérer ${sourceLabel(source)}'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _sync(SyncMode.FILL),
                  child: const Text('Compléter les champs vides'),
                ),
                TextButton(
                  onPressed: _busy ? null : () => _sync(SyncMode.REPLACE),
                  child: const Text('Tout remplacer par la fusion'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Touche « Utiliser » sous la valeur d\'une source pour la reprendre dans le livre.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            for (final field in metadataFields.keys)
              _FieldCard(
                field: field,
                book: book,
                merged: data.merged,
                known: known,
                disputed: data.differences.contains(field),
                onUse: _busy ? null : (source) => _apply(source, [field]),
              ),
            if (known.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Reprendre une source entière', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final source in known.keys)
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _apply(source, [
                                for (final field in metadataFields.keys)
                                  if (sourceValue(known[source]!, field) != null) field,
                              ]),
                      child: Text('Tout prendre de ${sourceLabel(source)}'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.book,
    required this.merged,
    required this.known,
    required this.disputed,
    required this.onUse,
  });

  final String field;
  final BookResponse book;
  final SourceMetadataResponse? merged;
  final Map<MetadataSource, SourceMetadataResponse> known;
  final bool disputed;
  final void Function(MetadataSource source)? onUse;

  bool get _isCover => field == 'cover';

  @override
  Widget build(BuildContext context) {
    final current = bookValue(book, field);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: disputed ? AppColors.star : AppColors.border, width: disputed ? 1.5 : 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(metadataFields[field]!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              if (disputed) ...[
                const SizedBox(width: 8),
                const Text('différent', style: TextStyle(fontSize: 12, color: AppColors.starOutline)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _ValueRow(
            label: 'Livre',
            emphasis: true,
            child: _isCover
                ? BookCover(title: book.title, authors: book.authors, imageUrl: book.cover?.thumbUrl, width: 60)
                : _text(current),
          ),
          if (merged != null && !_isCover) _ValueRow(label: 'Fusion', child: _text(sourceValue(merged!, field))),
          for (final source in externalSources)
            if (known[source] case final answer?)
              _ValueRow(
                label: sourceLabel(source),
                action: sourceValue(answer, field) == null || onUse == null
                    ? null
                    : TextButton(onPressed: () => onUse!(source), child: const Text('Utiliser')),
                child: _isCover ? _coverOf(answer) : _text(sourceValue(answer, field)),
              ),
        ],
      ),
    );
  }

  Widget _coverOf(SourceMetadataResponse answer) {
    final url = answer.coverUrl;
    if (url == null) {
      return _text(null);
    }
    return Image.network(
      url,
      width: 60,
      fit: BoxFit.contain,
      // Some sources refuse to be shown from another site: the link stays readable.
      errorBuilder: (_, _, _) => SelectableText(url, style: const TextStyle(fontSize: 12)),
    );
  }

  static Widget _text(String? value) => value == null
      ? const Text('—', style: TextStyle(color: AppColors.textSecondary))
      : SelectableText(value, maxLines: 6, style: const TextStyle(fontSize: 14, height: 1.4));
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.child, this.action, this.emphasis = false});

  final String label;
  final Widget child;
  final Widget? action;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: emphasis ? AppColors.text : AppColors.textSecondary,
                fontWeight: emphasis ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(child: child),
          ?action,
        ],
      ),
    );
  }
}
