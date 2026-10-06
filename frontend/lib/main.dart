import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router.dart';
import 'core/theme.dart';

void main() {
  // No automatic retry of failed requests: screens offer a "Réessayer" button instead.
  runApp(ProviderScope(retry: (_, _) => null, child: const LibraryApp()));
}

class LibraryApp extends ConsumerWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Library',
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      // google_sign_in_web still builds its button with package:flutter/material.dart: remove the
      // bridge once it moves to material_ui.
      // ignore: deprecated_member_use
      builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
    );
  }
}
