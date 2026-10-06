import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../books/book_actions.dart';
import '../books/book_cover.dart';
import '../books/reading_labels.dart';
import 'book_draft.dart';
import 'book_fields.dart';
import 'category_picker.dart';

/// Mock-ups 3-4 (Scan, Confirmation d'ajout) and Web · Ajout: ISBN first, then a pre-filled book to confirm.
class AddBookPanel extends ConsumerStatefulWidget {
  const AddBookPanel({super.key, this.initialIsbn, required this.onAdded, required this.onScan});

  final String? initialIsbn;

  /// The book was added and the user is done.
  final ValueChanged<BookResponse> onAdded;

  /// Opens the camera; returns the scanned ISBN, or null.
  final Future<String?> Function() onScan;

  @override
  ConsumerState<AddBookPanel> createState() => _AddBookPanelState();
}

class _AddBookPanelState extends ConsumerState<AddBookPanel> {
  final _isbn = TextEditingController();
  final _isbnFocus = FocusNode();
  bool _searching = false;
  bool _saving = false;
  String? _message;
  IsbnLookupResponse? _lookup;
  BookDraft? _draft;
  bool _editing = false;
  ReadingStatus? _status = ReadingStatus.TO_READ;

  @override
  void initState() {
    super.initState();
    final isbn = widget.initialIsbn;
    if (isbn != null && isbn.isNotEmpty) {
      _isbn.text = isbn;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _isbn.dispose();
    _isbnFocus.dispose();
    _draft?.dispose();
    super.dispose();
  }

  void _setDraft(BookDraft? draft, {required bool editing, IsbnLookupResponse? lookup, String? message}) {
    _draft?.dispose();
    setState(() {
      _draft = draft;
      _editing = editing;
      _lookup = lookup;
      _message = message;
    });
  }

  Future<void> _search() async {
    final raw = _isbn.text.trim();
    if (raw.isEmpty) {
      setState(() => _message = 'Saisis un ISBN de 10 ou 13 chiffres.');
      return;
    }
    setState(() {
      _searching = true;
      _message = null;
    });
    try {
      final lookup = (await ref.read(libraryApiProvider).getLookupApi().lookupIsbn(isbn: raw)).data!;
      _setDraft(lookup.existingBookId == null ? BookDraft.fromLookup(lookup) : null, editing: false, lookup: lookup);
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 400:
          _setDraft(null, editing: false, message: 'Cet ISBN n\'est pas valide : vérifie les chiffres.');
        case 404:
          _setDraft(
            BookDraft(isbn: raw),
            editing: true,
            message: 'Livre introuvable sur Open Library et Google Books : complète les informations.',
          );
        default:
          _setDraft(BookDraft(isbn: raw), editing: true, message: errorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _scan() async {
    final isbn = await widget.onScan();
    if (isbn != null && isbn.isNotEmpty && mounted) {
      _isbn.text = isbn;
      await _search();
    } else if (isbn != null) {
      _isbnFocus.requestFocus();
    }
  }

  void _manual() => _setDraft(BookDraft(), editing: true);

  void _reset() {
    _isbn.clear();
    _setDraft(null, editing: false);
    _status = ReadingStatus.TO_READ;
    _isbnFocus.requestFocus();
  }

  Future<void> _submit({required bool next}) async {
    final draft = _draft!;
    final problem = draft.validate();
    if (problem != null) {
      setState(() {
        _message = problem;
        _editing = true;
      });
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final book = await ref.read(bookActionsProvider).save(null, draft.toRequest());
      final status = _status;
      if (draft.owned && status != null) {
        await ref.read(libraryApiProvider).getBooksApi().saveMyReading(
              id: book.id,
              readingRequest: ReadingRequest(status: status),
            );
      }
      if (next) {
        messenger.showSnackBar(SnackBar(content: Text('« ${book.title} » ajouté.')));
        _reset();
      } else {
        widget.onAdded(book);
      }
    } catch (e) {
      setState(() => _message = errorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final lookup = _lookup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IsbnRow(
          controller: _isbn,
          focusNode: _isbnFocus,
          searching: _searching,
          onSearch: _search,
          onScan: _scan,
        ),
        if (draft == null && lookup?.existingBookId == null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: _manual, child: const Text('Pas d\'ISBN ? Saisie manuelle')),
          ),
        if (_message != null) ...[const SizedBox(height: 12), MessageBox.error(_message!)],
        if (lookup?.existingBookId case final id?) ...[
          const SizedBox(height: 16),
          _AlreadyThere(title: lookup!.title, onOpen: () => context.push('/books/$id')),
        ],
        if (draft != null) ...[
          const SizedBox(height: 20),
          _Preview(
            draft: draft,
            source: lookup?.source_,
            editing: _editing,
            onEdit: () => setState(() => _editing = !_editing),
          ),
          if (_editing) ...[const SizedBox(height: 16), BookFields(draft: draft)],
          const SizedBox(height: 22),
          const _Label('Je l\'ajoute à'),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('Ma bibliothèque')),
              ButtonSegment(value: false, label: Text('Ma liste d\'envies')),
            ],
            selected: {draft.owned},
            onSelectionChanged: (selection) => setState(() => draft.owned = selection.first),
          ),
          if (draft.owned) ...[
            const SizedBox(height: 22),
            const _Label('Mon statut'),
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
                    onSelected: (on) => setState(() => _status = on ? status : null),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          const _Label('Catégories'),
          CategoryPicker(
            selected: draft.categoryIds,
            onChanged: (ids) => setState(() => draft.categoryIds
              ..clear()
              ..addAll(ids)),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : () => _submit(next: false),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: Text(draft.owned ? 'Ajouter à ma bibliothèque' : 'Ajouter à ma liste d\'envies'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _saving ? null : () => _submit(next: true),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(kIsWeb ? 'Ajouter et continuer' : 'Ajouter et scanner le suivant'),
          ),
        ],
      ],
    );
  }
}

class _IsbnRow extends StatelessWidget {
  const _IsbnRow({
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.onSearch,
    required this.onScan,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final VoidCallback onSearch;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 420),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(labelText: 'ISBN', hintText: '978…'),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        FilledButton(
          onPressed: searching ? null : onSearch,
          child: searching
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Chercher'),
        ),
        OutlinedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(kIsWeb ? 'Webcam' : 'Scanner'),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.draft, required this.source, required this.editing, required this.onEdit});

  final BookDraft draft;
  final MetadataSource? source;
  final bool editing;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = switch (source) {
      MetadataSource.OPEN_LIBRARY => 'Trouvé sur Open Library',
      MetadataSource.GOOGLE_BOOKS => 'Trouvé sur Google Books',
      _ => null,
    };
    return ListenableBuilder(
      listenable: Listenable.merge([draft.title, draft.authors, draft.publisher, draft.year, draft.pages]),
      builder: (context, _) {
        final title = draft.title.text.trim();
        final authors = draft.authors.text.trim();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF6F7F4), borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(title: title.isEmpty ? '?' : title, authors: authors.isEmpty ? null : authors, width: 104),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sourceLabel != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sourceLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                        ),
                      ),
                    Text(
                      title.isEmpty ? 'Nouveau livre' : title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
                    ),
                    if (authors.isNotEmpty)
                      Text(authors, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    if (draft.details().isNotEmpty)
                      Text(draft.details(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (draft.isbn != null)
                      Text('ISBN ${draft.isbn}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: onEdit,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(editing ? 'Masquer le formulaire' : 'Modifier les infos'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AlreadyThere extends StatelessWidget {
  const _AlreadyThere({required this.title, required this.onOpen});

  final String title;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(child: Text('« $title » est déjà dans la bibliothèque.', style: const TextStyle(fontSize: 15))),
          TextButton(onPressed: onOpen, child: const Text('Voir la fiche')),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}
