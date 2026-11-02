import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../books/book_cover.dart';
import 'series_labels.dart';
import 'series_providers.dart';

/// One series, volume by volume: the albums of the library, the wished ones and the missing numbers.
class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(seriesBooksProvider(name));
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: switch (books) {
        AsyncValue(:final value?) => _content(context, value),
        AsyncValue(:final error?) => Padding(
            padding: const EdgeInsets.all(16),
            child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(seriesBooksProvider(name))),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, List<BookResponse> books) {
    final numbered = <int, List<BookResponse>>{};
    final unnumbered = <BookResponse>[];
    for (final book in books) {
      final number = book.seriesNumber;
      if (number == null || number < 1) {
        unnumbered.add(book);
      } else {
        numbered.putIfAbsent(number, () => []).add(book);
      }
    }
    final last = numbered.keys.fold(0, (a, b) => a > b ? a : b);
    final shownLast = last > 500 ? numbered.keys.length : last;
    final volumes = last > 500 ? (numbered.keys.toList()..sort()) : [for (var n = 1; n <= last; n++) n];
    final owned = volumes.where((n) => numbered[n]?.any((b) => b.owned) ?? false).length;
    final missing = volumes.where((n) => !(numbered[n]?.any((b) => b.owned) ?? false)).toList();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(
              [
                if (last > 0) '$owned tome${owned > 1 ? 's' : ''} sur $shownLast dans la bibliothèque',
                if (missing.isNotEmpty) 'manque ${volumeRanges(missing)}',
              ].join(' · '),
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (last > 0)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Les tomes après le dernier connu ne sont pas comptés.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(height: 12),
            for (final number in volumes)
              if (numbered[number] case final present?)
                for (final book in present) _VolumeTile(number: number, book: book)
              else
                _VolumeTile(number: number),
            if (unnumbered.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Sans numéro de tome', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              for (final book in unnumbered) _VolumeTile(book: book),
            ],
          ],
        ),
      ),
    );
  }
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({this.number, this.book});

  final int? number;
  final BookResponse? book;

  @override
  Widget build(BuildContext context) {
    final book = this.book;
    final label = number == null ? null : 'Tome $number';
    if (book == null) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        leading: Container(
          width: 44,
          height: 66,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text('$number', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        title: Text(label!, style: const TextStyle(color: AppColors.textSecondary)),
        subtitle: const Text('Manquant', style: TextStyle(color: AppColors.error)),
      );
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: BookCover(title: book.title, imageUrl: book.cover?.thumbUrl, width: 44, showText: false),
      title: Text(
        label == null ? book.title : '$label · ${book.title}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [if (book.authors != null) book.authors!, if (!book.owned) 'Dans la liste d\'envies'].join('\n'),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontStyle: book.owned ? FontStyle.normal : FontStyle.italic,
        ),
      ),
      onTap: () => context.push('/books/${book.id}'),
    );
  }
}
