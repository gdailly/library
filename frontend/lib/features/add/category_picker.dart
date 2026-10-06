import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../settings/category_dialog.dart';
import '../settings/settings_providers.dart';

/// Toggles the categories of a book; "+ Nouvelle" creates one and selects it.
class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({super.key, required this.selected, required this.onChanged});

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          FilterChip(
            label: Text(category.name),
            selected: selected.contains(category.id),
            showCheckmark: true,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(color: selected.contains(category.id) ? Colors.white : AppColors.text),
            onSelected: (on) => onChanged(on ? {...selected, category.id} : ({...selected}..remove(category.id))),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Nouvelle'),
          side: const BorderSide(color: Color(0xFFA9ABA4)),
          onPressed: () async {
            final created = await showCategoryDialog(context);
            if (created != null) {
              onChanged({...selected, created.id});
            }
          },
        ),
      ],
    );
  }
}
