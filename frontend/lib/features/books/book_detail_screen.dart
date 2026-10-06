import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import 'book_actions.dart';
import 'book_cover.dart';
import 'books_providers.dart';
import 'edit_book_dialog.dart';
import 'reading_labels.dart';

/// Mock-up 5 · Fiche livre: the shared book and the user's own reading.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (book.value case final loaded?) ...[
            IconButton(
              tooltip: 'Modifier',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showEditBookDialog(context, loaded),
            ),
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, loaded),
            ),
          ],
        ],
      ),
      body: switch (book) {
        AsyncValue(:final value?) => _BookDetail(book: value),
        AsyncValue(:final error?) => Padding(
            padding: const EdgeInsets.all(16),
            child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(bookProvider(bookId))),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _BookDetail extends StatelessWidget {
  const _BookDetail({required this.book});

  final BookResponse book;

  @override
  Widget build(BuildContext context) {
    final details = [
      book.publisher,
      book.year?.toString(),
      if (book.pages != null) '${book.pages} p.',
      if (book.isbn13 != null) 'ISBN ${book.isbn13}',
    ].whereType<String>().join(' · ');
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Center(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8))],
            ),
            child: BookCover(
              title: book.title,
              authors: book.authors,
              imageUrl: book.cover?.mediumUrl,
              width: 150,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(book.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
        if (book.subtitle != null)
          Text(book.subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        if (book.authors != null) ...[
          const SizedBox(height: 6),
          Text(
            book.authors!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
        if (details.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(details, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
        if (book.categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final category in book.categories)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(category.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        ReadingCard(book: book),
        if (book.otherReadings.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text('Les autres lecteurs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          for (final reading in book.otherReadings) _OtherReader(reading: reading),
        ],
        if (book.summary != null) ...[
          const SizedBox(height: 22),
          const Text('Résumé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(book.summary!, style: const TextStyle(fontSize: 15, height: 1.55, color: Color(0xFF3A3F45))),
        ],
      ],
    );
  }
}

/// "Mon suivi": status, rating and review, saved together.
class ReadingCard extends ConsumerStatefulWidget {
  const ReadingCard({super.key, required this.book});

  final BookResponse book;

  @override
  ConsumerState<ReadingCard> createState() => _ReadingCardState();
}

class _ReadingCardState extends ConsumerState<ReadingCard> {
  late ReadingStatus? _status = widget.book.myReading?.status;
  late int? _rating = widget.book.myReading?.rating;
  late final _review = TextEditingController(text: widget.book.myReading?.review);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  Future<void> _save({ReadingStatus? status, int? Function()? rating}) async {
    final newStatus = status ?? _status;
    if (newStatus == null) {
      // A rating or a review needs a status first.
      setState(() => _error = 'Choisis d\'abord un statut de lecture.');
      return;
    }
    final newRating = rating == null ? _rating : rating();
    setState(() {
      _status = newStatus;
      _rating = newRating;
      _saving = true;
      _error = null;
    });
    final reading = widget.book.myReading;
    try {
      await ref.read(libraryApiProvider).getBooksApi().saveMyReading(
            id: widget.book.id,
            readingRequest: ReadingRequest(
              status: newStatus,
              rating: newRating,
              review: _review.text.trim().isEmpty ? null : _review.text.trim(),
              startedOn: reading?.startedOn,
              finishedOn: reading?.finishedOn,
            ),
          );
      ref.invalidate(bookProvider(widget.book.id));
      ref.invalidate(booksProvider);
    } catch (e) {
      setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reading = widget.book.myReading;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Mon suivi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              if (_saving) const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final MapEntry(key: status, value: label) in readingStatusLabels.entries)
                ChoiceChip(
                  label: Text(label),
                  selected: _status == status,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _status == status ? Colors.white : AppColors.text),
                  onSelected: _saving ? null : (_) => _save(status: status),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: '$star sur 5',
                  constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    (_rating ?? 0) >= star ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: (_rating ?? 0) >= star ? AppColors.star : AppColors.starOutline,
                    size: 32,
                  ),
                  onPressed: _saving ? null : () => _save(rating: () => _rating == star ? null : star),
                ),
              const SizedBox(width: 8),
              Text(
                _rating == null ? 'Pas de note' : '$_rating / 5',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _review,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Mon avis'),
            onEditingComplete: () => _save(),
            onTapOutside: (_) {
              if (_review.text.trim() != (reading?.review ?? '')) {
                _save();
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
          if (_readingDates(reading) case final dates?) ...[
            const SizedBox(height: 10),
            Text(dates, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            MessageBox.error(_error!),
          ],
        ],
      ),
    );
  }

  static String? _readingDates(ReadingResponse? reading) {
    String date(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final start = reading?.startedOn;
    final end = reading?.finishedOn;
    return switch ((start, end)) {
      (final s?, final e?) => 'Lu du ${date(s)} au ${date(e)}',
      (final s?, null) => 'Commencé le ${date(s)}',
      (null, final e?) => 'Terminé le ${date(e)}',
      _ => null,
    };
  }
}

/// Asks before deleting: the book disappears for every member, with their readings.
Future<void> _delete(BuildContext context, WidgetRef ref, BookResponse book) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Supprimer « ${book.title} » ?'),
      content: const Text('Le livre disparaît pour tous les membres, avec leurs notes et avis.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  if (!(confirmed ?? false) || !context.mounted) {
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    await ref.read(bookActionsProvider).delete(book.id);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text('« ${book.title} » supprimé.')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
  }
}

class _OtherReader extends StatelessWidget {
  const _OtherReader({required this.reading});

  final OtherReadingResponse reading;

  @override
  Widget build(BuildContext context) {
    final summary = [
      readingStatusLabels[reading.status],
      if (reading.rating case final rating?) '${'★' * rating}${'☆' * (5 - rating)}',
      if (reading.review case final review?) '« $review »',
    ].whereType<String>().join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: BookCover.colorFor(reading.name),
            child: Text(
              reading.name.characters.first.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reading.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(summary, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
