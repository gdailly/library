import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../shared/app_logo.dart';
import '../add/add_book_screen.dart';
import '../auth/auth_controller.dart';

/// Main navigation: bottom bar and "Scanner" button on phones, side menu from 1024 px (web mock-ups).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: Icons.auto_stories_outlined, label: 'Bibliothèque'),
    (icon: Icons.favorite_border, label: 'Envies'),
    (icon: Icons.tune, label: 'Réglages'),
  ];

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  /// Phones: camera first, then the confirmation page (typing the ISBN if the user asks to).
  Future<void> _scan(BuildContext context) async {
    final isbn = await scanIsbn(context);
    if (isbn != null && context.mounted) {
      await context.push(isbn.isEmpty ? '/add' : '/add?isbn=$isbn');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.sizeOf(context).width >= 1024) {
      return Scaffold(
        body: Row(
          children: [
            _SideMenu(
              selected: shell.currentIndex,
              onSelected: _go,
              onAdd: () => showAddBookDialog(context),
              onSignOut: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(child: shell),
      floatingActionButton: shell.currentIndex < 2
          ? FloatingActionButton.extended(
              onPressed: () => _scan(context),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final d in _destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.selected,
    required this.onSelected,
    required this.onAdd,
    required this.onSignOut,
  });

  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppLogo(size: 36),
              const SizedBox(width: 10),
              Text('Library', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Ajouter un livre')),
          const SizedBox(height: 24),
          for (final (index, d) in HomeShell._destinations.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                selected: index == selected,
                selectedTileColor: AppColors.accentLight,
                selectedColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(d.icon),
                title: Text(d.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => onSelected(index),
              ),
            ),
          const Spacer(),
          TextButton.icon(onPressed: onSignOut, icon: const Icon(Icons.logout), label: const Text('Se déconnecter')),
        ],
      ),
    );
  }
}

