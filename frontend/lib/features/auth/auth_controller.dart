import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../../core/api.dart';
import 'google_auth_gateway.dart';

sealed class AuthState {
  const AuthState();

  String? get idToken => null;
}

/// Restoring a previous session.
class AuthStarting extends AuthState {
  const AuthStarting();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.message});

  /// Why the user is signed out, shown on the sign-in screen.
  final String? message;
}

/// Signed in with Google and member of a library ([me]).
class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.token, required this.me});

  final String token;
  final MeResponse me;

  @override
  String get idToken => token;
}

/// Google provides the identity, the API decides access: a Google account is signed in
/// only once GET /api/me accepted its token.
class AuthController extends Notifier<AuthState> {
  static const notInvited = "Ce compte Google n'est pas invité. Demande l'accès au propriétaire de la bibliothèque.";
  static const expired = 'Ta session a expiré, reconnecte-toi.';

  StreamSubscription<String?>? _events;
  String? _checking;

  @override
  AuthState build() {
    ref.onDispose(() => _events?.cancel());
    unawaited(_start());
    return const AuthStarting();
  }

  GoogleAuthGateway get _gateway => ref.read(googleAuthGatewayProvider);

  Future<void> _start() async {
    try {
      await _gateway.initialize();
      _events = _gateway.idTokens.listen(
        _onToken,
        onError: (Object _) => state = const AuthSignedOut(),
      );
      final restored = _gateway.restore();
      if (restored == null) {
        // The platform answers through idTokens, maybe never: show the sign-in screen meanwhile.
        _settleSignedOut();
        return;
      }
      final token = await restored;
      token == null ? _settleSignedOut() : await _onToken(token);
    } catch (_) {
      state = const AuthSignedOut(message: 'Connexion Google indisponible.');
    }
  }

  void _settleSignedOut() {
    if (state is AuthStarting) {
      state = const AuthSignedOut();
    }
  }

  /// Interactive sign-in where the platform allows it (Android).
  Future<void> signIn() async {
    try {
      final token = await _gateway.signIn();
      if (token != null) {
        await _onToken(token);
      }
    } catch (_) {
      // Cancelled by the user or refused by Google: stay on the sign-in screen.
    }
  }

  Future<void> signOut({String? message}) async {
    state = AuthSignedOut(message: message);
    await _gateway.signOut();
  }

  /// The API refused the token (expired after about an hour).
  void sessionExpired() {
    if (state is AuthSignedIn) {
      unawaited(signOut(message: expired));
    }
  }

  Future<void> _onToken(String? token) async {
    if (token == null) {
      state = const AuthSignedOut();
      return;
    }
    if (token == state.idToken || token == _checking) {
      return;
    }
    _checking = token;
    try {
      final me = await ref.read(libraryApiProvider).getMeApi().getMe(
        headers: {'Authorization': 'Bearer $token'},
      );
      state = AuthSignedIn(token: token, me: me.data!);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      await signOut(
        message: status == 403
            ? notInvited
            : status == 401
                ? 'Google a refusé la connexion. Réessaie.'
                : errorMessage(e),
      );
    } finally {
      _checking = null;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
