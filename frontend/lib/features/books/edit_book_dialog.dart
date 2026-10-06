import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../shared/message_box.dart';
import '../add/book_draft.dart';
import '../add/book_fields.dart';
import '../add/category_picker.dart';
import 'book_actions.dart';

/// Edits the shared information of a book: full screen on phones, a dialog on wide screens.
Future<void> showEditBookDialog(BuildContext context, BookResponse book) {
  final wide = MediaQuery.sizeOf(context).width >= 1024;
  return showDialog<void>(
    context: context,
    builder: (_) => wide
        ? Dialog(
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: _EditBook(book: book)),
          )
        : Dialog.fullscreen(child: _EditBook(book: book)),
  );
}

class _EditBook extends ConsumerStatefulWidget {
  const _EditBook({required this.book});

  final BookResponse book;

  @override
  ConsumerState<_EditBook> createState() => _EditBookState();
}

class _EditBookState extends ConsumerState<_EditBook> {
  late final _draft = BookDraft.fromBook(widget.book);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = _draft.validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(bookActionsProvider).save(widget.book.id, _draft.toRequest());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le livre'),
        leading: IconButton(
          tooltip: 'Annuler',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(onPressed: _saving ? null : _save, child: const Text('Enregistrer')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (_error != null) ...[MessageBox.error(_error!), const SizedBox(height: 16)],
          BookFields(draft: _draft),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dans ma bibliothèque'),
            subtitle: const Text('Désactivé : le livre est dans la liste d\'envies.'),
            value: _draft.owned,
            onChanged: (owned) => setState(() => _draft.owned = owned),
          ),
          const SizedBox(height: 12),
          const Text('Catégories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CategoryPicker(
            selected: _draft.categoryIds,
            onChanged: (ids) => setState(() => _draft.categoryIds
              ..clear()
              ..addAll(ids)),
          ),
        ],
      ),
    );
  }
}
