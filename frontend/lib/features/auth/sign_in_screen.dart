import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../core/theme.dart';
import '../../shared/app_logo.dart';
import '../../shared/message_box.dart';
import 'auth_controller.dart';
import 'google_button.dart';

/// Mock-ups 1 · Connexion (mobile) and Web · Connexion (two panes from 1024 px).
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  static const tagline = 'Ta bibliothèque, partagée avec tes proches.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);
    final configured = ref.watch(appConfigProvider).hasGoogleClientId;
    final message = switch (state) {
      AuthSignedOut(:final message) => message,
      _ => null,
    };
    final form = _SignInForm(
      message: configured ? message : 'GOOGLE_CLIENT_ID manquant : lance l\'app avec --dart-define=GOOGLE_CLIENT_ID=…',
      loading: state is AuthStarting,
      enabled: configured,
      onSignIn: () => ref.read(authControllerProvider.notifier).signIn(),
    );
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 1024
            ? Row(
                children: [
                  const Expanded(child: _WelcomePane()),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: form),
                    ),
                  ),
                ],
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppLogo(size: 88),
                            const SizedBox(height: 20),
                            Text('Library', style: Theme.of(context).textTheme.displaySmall),
                            const SizedBox(height: 12),
                            const Text(
                              tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17, height: 1.45, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      form,
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.message,
    required this.loading,
    required this.enabled,
    required this.onSignIn,
  });

  final String? message;
  final bool loading;
  final bool enabled;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (MediaQuery.sizeOf(context).width >= 1024) ...[
          Text('Connexion', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          const Text(
            'Connecte-toi avec le compte Google invité par le propriétaire de la bibliothèque.',
            style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
        ],
        if (message != null) ...[
          MessageBox.error(message!),
          const SizedBox(height: 16),
        ],
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (enabled)
          Center(child: GoogleButton(onPressed: onSignIn)),
        const SizedBox(height: 16),
        const Text(
          'Accès réservé aux comptes invités par le propriétaire.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _WelcomePane extends StatelessWidget {
  const _WelcomePane();

  @override
  Widget build(BuildContext context) {
    final titles = Theme.of(context).textTheme;
    return ColoredBox(
      color: AppColors.accent,
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const AppLogo(size: 44, onAccent: true),
                const SizedBox(width: 12),
                Text('Library', style: titles.headlineSmall?.copyWith(color: Colors.white)),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SignInScreen.tagline,
                    style: titles.displayMedium?.copyWith(color: Colors.white, height: 1.02),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Scanne un code-barres, retrouve un livre en un instant, note tes lectures et garde ta liste d\'envies.',
                    style: TextStyle(fontSize: 18, height: 1.5, color: AppColors.accentLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
