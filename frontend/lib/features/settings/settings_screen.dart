import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/color_hex.dart';
import '../../shared/message_box.dart';
import '../auth/auth_controller.dart';
import 'category_dialog.dart';
import 'settings_providers.dart';

/// Mock-up 7 · Réglages: profile, categories, members (owners invite and remove), sign-out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth is! AuthSignedIn) {
      return const SizedBox.shrink();
    }
    final role = auth.me.libraries.firstOrNull?.role;
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final signOut = OutlinedButton(
      onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, minimumSize: const Size(44, 48)),
      child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600)),
    );
    const categories = _CategoriesSection();
    final members = _MembersSection(isOwner: role == Role.OWNER, myId: auth.me.id);
    const recognition = _Card(
      child: ListTile(
        title: Text('Reconnaissance photo par IA'),
        subtitle: Text('Couverture et étagère · lots 2 et 3 · configurée sur le serveur'),
        trailing: _Badge('Désactivée'),
      ),
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 24, 16, wide ? 32 : 104),
      children: [
        Row(
          children: [
            Expanded(child: Text('Réglages', style: Theme.of(context).textTheme.headlineMedium)),
            if (wide) ...[_Profile(me: auth.me, role: role, compact: true), const SizedBox(width: 12), signOut],
          ],
        ),
        const SizedBox(height: 24),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: categories),
              const SizedBox(width: 24),
              Expanded(child: Column(children: [members, const SizedBox(height: 24), recognition])),
            ],
          )
        else ...[
          _Profile(me: auth.me, role: role),
          const SizedBox(height: 24),
          categories,
          const SizedBox(height: 24),
          members,
          const SizedBox(height: 24),
          recognition,
          const SizedBox(height: 24),
          signOut,
        ],
      ],
    );
  }
}

String roleLabel(Role? role) => role == Role.OWNER ? 'Propriétaire' : 'Membre';

class _Profile extends StatelessWidget {
  const _Profile({required this.me, required this.role, this.compact = false});

  final MeResponse me;
  final Role? role;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      contentPadding: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: _Avatar(name: me.name ?? me.email, url: me.avatarUrl),
      title: Text(me.name ?? me.email, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${me.email} · ${roleLabel(role)}'),
    );
    return compact ? SizedBox(width: 360, child: tile) : _Card(child: tile);
  }
}

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return _Section(
      title: 'Catégories',
      children: [
        ...switch (categories) {
          AsyncValue(:final value?) => [
              for (final category in value)
                ListTile(
                  leading: CircleAvatar(radius: 6, backgroundColor: colorFromHex(category.color)),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _books(category.bookCount ?? 0),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      IconButton(
                        tooltip: 'Modifier la catégorie ${category.name}',
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => showCategoryDialog(context, category: category),
                      ),
                    ],
                  ),
                ),
            ],
          AsyncValue(:final error?) => [
              Padding(
                padding: const EdgeInsets.all(12),
                child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(categoriesProvider)),
              ),
            ],
          _ => [const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))],
        },
        ListTile(
          leading: const Icon(Icons.add, color: AppColors.accent),
          title: const Text(
            'Ajouter une catégorie',
            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
          onTap: () => showCategoryDialog(context),
        ),
      ],
    );
  }

  static String _books(int count) => count <= 1 ? '$count livre' : '$count livres';
}

class _MembersSection extends ConsumerStatefulWidget {
  const _MembersSection({required this.isOwner, required this.myId});

  final bool isOwner;
  final int myId;

  @override
  ConsumerState<_MembersSection> createState() => _MembersSectionState();
}

class _MembersSectionState extends ConsumerState<_MembersSection> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  MembersApi get _api => ref.read(libraryApiProvider).getMembersApi();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      ref.invalidate(membersProvider);
    } catch (e) {
      _error = errorMessage(e);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _invite() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Saisis l\'adresse e-mail Google à inviter.');
      return;
    }
    await _run(() async {
      await _api.inviteMember(memberRequest: MemberRequest(email: email));
      _email.clear();
    });
  }

  Future<void> _remove(MemberResponse member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Retirer ${member.name ?? member.email} ?'),
        content: const Text('Cette personne n\'aura plus accès à la bibliothèque.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await _run(() => _api.removeMember(userId: member.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider);
    return _Section(
      title: 'Membres de la bibliothèque',
      children: [
        ...switch (members) {
          AsyncValue(:final value?) => [
              for (final member in value)
                ListTile(
                  leading: _Avatar(name: member.name ?? member.email, url: member.avatarUrl, size: 36),
                  title: Text(member.name ?? member.email),
                  subtitle: member.name == null ? const Text('Pas encore connecté') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        roleLabel(member.role),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      if (widget.isOwner && member.userId != widget.myId)
                        IconButton(
                          tooltip: 'Retirer ${member.name ?? member.email}',
                          color: AppColors.error,
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _busy ? null : () => _remove(member),
                        ),
                    ],
                  ),
                ),
            ],
          AsyncValue(:final error?) => [
              Padding(
                padding: const EdgeInsets.all(12),
                child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(membersProvider)),
              ),
            ],
          _ => [const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()))],
        },
        if (widget.isOwner)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'E-mail Google à inviter', isDense: true),
                    onSubmitted: (_) => _invite(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _busy ? null : _invite, child: const Text('Inviter')),
              ],
            ),
          ),
        if (_error != null) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: MessageBox.error(_error!)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        _Card(child: Column(children: children)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A Material, not a decorated box, so that list tiles show their ink.
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }
}

/// Google photo, or the initial on the accent color.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.url, this.size = 48});

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.accent,
      foregroundImage: url == null ? null : NetworkImage(url!),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
