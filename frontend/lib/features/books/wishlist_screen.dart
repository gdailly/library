import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../../shared/search_field.dart';
import 'book_actions.dart';
import 'book_cover.dart';
import 'books_providers.dart';

/// Mock-up 6 · Liste d'envies: books not owned yet, shared by the members; "Je l'ai" moves one to the library.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(wishlistQueryProvider);
    final wishes = ref.watch(booksProvider(query));
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Liste d\'envies', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  wishes.hasValue ? _count(wishes.requireValue.totalItems) : ' ',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                SearchField(
                  hint: 'Rechercher dans mes envies',
                  onChanged: ref.read(wishlistQueryProvider.notifier).search,
                ),
              ],
            ),
          ),
        ),
        ...switch (wishes) {
          AsyncValue(:final value?) when value.items.isEmpty => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    query.text.isEmpty
                        ? 'Aucune envie pour l\'instant : ajoute un livre à ta liste d\'envies depuis l\'ajout.'
                        : 'Aucune envie trouvée.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          AsyncValue(:final value?) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: value.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) => _WishTile(book: value.items[index]),
                ),
              ),
            ],
          AsyncValue(:final error?) => [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(booksProvider(query))),
                ),
              ),
            ],
          _ => [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
        },
      ],
    );
  }

  static String _count(int total) => total <= 1 ? '$total envie' : '$total envies';
}

class _WishTile extends ConsumerStatefulWidget {
  const _WishTile({required this.book});

  final BookResponse book;

  @override
  ConsumerState<_WishTile> createState() => _WishTileState();
}

class _WishTileState extends ConsumerState<_WishTile> {
  bool _busy = false;

  Future<void> _markOwned() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(bookActionsProvider).markOwned(widget.book);
      messenger.showSnackBar(SnackBar(content: Text('« ${widget.book.title} » est dans ta bibliothèque.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return InkWell(
      onTap: () => context.push('/books/${book.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            BookCover(title: book.title, imageUrl: book.cover?.thumbUrl, width: 44, showText: false),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (book.authors != null)
                    Text(book.authors!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  if (book.addedByName != null)
                    Text(
                      'Ajouté par ${book.addedByName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _busy ? null : _markOwned,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: const StadiumBorder(),
                minimumSize: const Size(44, 40),
              ),
              child: const Text('Je l\'ai', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
