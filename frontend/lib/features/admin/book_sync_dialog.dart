import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../books/books_providers.dart';

/// French names of the fields reported by a resynchronisation.
const syncFieldLabels = {
  'title': 'titre',
  'subtitle': 'sous-titre',
  'authors': 'auteurs',
  'publisher': 'éditeur',
  'year': 'année',
  'pages': 'pages',
  'language': 'langue',
  'summary': 'résumé',
  'cover': 'couverture',
};

/// What a resynchronisation did, in one sentence.
String syncSummary(BookSyncResponse result) => switch (result.outcome) {
      SyncOutcome.NOT_FOUND => 'Aucune source ne connaît cet ISBN.',
      SyncOutcome.UNCHANGED => 'Rien à mettre à jour : le livre est déjà à jour.',
      SyncOutcome.UPDATED => 'Mis à jour : ${result.changedFields.map((f) => syncFieldLabels[f] ?? f).join(', ')}.',
    };

/// Asks how to resynchronise a book (owners only), runs it and reports the result in a snack bar.
Future<void> showBookSyncDialog(BuildContext context, WidgetRef ref, BookResponse book) async {
  final mode = await showDialog<SyncMode>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text('Resynchroniser « ${book.title} »'),
      children: [
        _ModeOption(
          mode: SyncMode.FILL,
          title: 'Compléter les champs vides',
          subtitle: 'Garde tout ce qui est déjà renseigné.',
        ),
        _ModeOption(
          mode: SyncMode.REPLACE,
          title: 'Tout remplacer par les sources',
          subtitle: 'Titre, auteurs, résumé, couverture… remplacés par ce que trouvent la BnF, '
              'Open Library et Google Books. Les catégories et les avis ne changent pas.',
        ),
      ],
    ),
  );
  if (mode == null || !context.mounted) {
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Resynchronisation…')));
  try {
    final response = await ref
        .read(libraryApiProvider)
        .getAdminApi()
        .syncBookMetadata(id: book.id, mode: mode);
    ref
      ..invalidate(bookProvider(book.id))
      ..invalidate(booksProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(syncSummary(response.data!))));
  } catch (e) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage(e))));
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.mode, required this.title, required this.subtitle});

  final SyncMode mode;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: () => Navigator.of(context).pop(mode),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
