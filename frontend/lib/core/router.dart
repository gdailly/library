import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/add/add_book_screen.dart';
import '../features/add/scan_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/books/book_detail_screen.dart';
import '../features/books/library_screen.dart';
import '../features/books/wishlist_screen.dart';
import '../features/home/home_shell.dart';
import '../features/settings/settings_screen.dart';

/// Routes; everything but /login needs a signed-in member.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref
    ..listen(authControllerProvider, (_, state) => auth.value = state)
    ..onDispose(auth.dispose);
  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      final signedIn = auth.value is AuthSignedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!signedIn && !onLogin) {
        return '/login';
      }
      return signedIn && onLogin ? '/' : null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => const LibraryScreen())]),
          StatefulShellBranch(
            routes: [GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/add', builder: (_, state) => AddBookScreen(isbn: state.uri.queryParameters['isbn'])),
      GoRoute(
        path: '/books/:id',
        builder: (_, state) => BookDetailScreen(bookId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
});
