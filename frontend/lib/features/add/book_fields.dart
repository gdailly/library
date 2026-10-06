import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'book_draft.dart';

/// Title, authors and edition of a draft, as editable fields.
class BookFields extends StatelessWidget {
  const BookFields({super.key, required this.draft});

  final BookDraft draft;

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: draft.title,
          decoration: const InputDecoration(labelText: 'Titre *'),
          textCapitalization: TextCapitalization.sentences,
          maxLength: 500,
        ),
        TextField(
          controller: draft.subtitle,
          decoration: const InputDecoration(labelText: 'Sous-titre'),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: draft.authors,
          decoration: const InputDecoration(labelText: 'Auteurs', helperText: 'Séparés par des virgules'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: draft.publisher,
          decoration: const InputDecoration(labelText: 'Éditeur'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: draft.year,
                decoration: const InputDecoration(labelText: 'Année'),
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 4,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: draft.pages,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                inputFormatters: digits,
                maxLength: 5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
