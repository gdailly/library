import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/color_hex.dart';
import '../../shared/message_box.dart';
import '../books/books_providers.dart';
import 'settings_providers.dart';

/// Creates a category, or edits / deletes [category]; returns the saved category (null when cancelled or deleted).
Future<CategoryResponse?> showCategoryDialog(BuildContext context, {CategoryResponse? category}) =>
    showDialog<CategoryResponse>(context: context, builder: (_) => _CategoryDialog(category: category));

class _CategoryDialog extends ConsumerStatefulWidget {
  const _CategoryDialog({this.category});

  final CategoryResponse? category;

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  late final _name = TextEditingController(text: widget.category?.name);
  late String _color = widget.category?.color ?? categoryColors.first;
  bool _busy = false;
  String? _error;

  CategoriesApi get _api => ref.read(libraryApiProvider).getCategoriesApi();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<CategoryResponse?> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await action();
      ref
        ..invalidate(categoriesProvider)
        ..invalidate(booksProvider)
        ..invalidate(bookProvider);
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() {
        _busy = false;
        _error = errorMessage(e);
      });
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Donne un nom à la catégorie.');
      return;
    }
    final request = CategoryRequest(name: name, color: _color);
    final id = widget.category?.id;
    await _run(() async => (id == null
            ? await _api.createCategory(categoryRequest: request)
            : await _api.updateCategory(id: id, categoryRequest: request))
        .data);
  }

  Future<void> _delete() async {
    final count = widget.category?.bookCount ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie ?'),
        content: Text(
          count == 0
              ? 'Aucun livre n\'est classé dans « ${widget.category!.name} ».'
              : 'Les $count livres classés dans « ${widget.category!.name} » restent dans la bibliothèque.',
        ),
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
    if (confirmed ?? false) {
      await _run(() async {
        await _api.deleteCategory(id: widget.category!.id);
        return null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.category != null;
    return AlertDialog(
      title: Text(editing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Nom'),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            const Text('Couleur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: [
                for (final hex in categoryColors)
                  IconButton(
                    tooltip: hex,
                    onPressed: () => setState(() => _color = hex),
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: colorFromHex(hex),
                      child: _color == hex ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  ),
              ],
            ),
            if (_error != null) ...[const SizedBox(height: 12), MessageBox.error(_error!)],
          ],
        ),
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const Text('Annuler')),
        FilledButton(onPressed: _busy ? null : _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
