import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:material_ui/material_ui.dart';

/// The official "Sign in with Google" button rendered by Google Identity Services; its result
/// arrives through `GoogleSignIn.authenticationEvents`.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  /// Unused on the web: Google handles the click.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: web.GSIButtonType.standard,
          theme: web.GSIButtonTheme.outline,
          size: web.GSIButtonSize.large,
          text: web.GSIButtonText.signinWith,
          shape: web.GSIButtonShape.rectangular,
          locale: 'fr',
          minimumWidth: 320,
        ),
      ),
    );
  }
}
