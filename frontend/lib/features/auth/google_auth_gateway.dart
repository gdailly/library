import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config.dart';

/// What the app needs from Google Sign-In: Google ID tokens, sent as Bearer to the API.
abstract interface class GoogleAuthGateway {
  Future<void> initialize();

  /// ID tokens of accounts that sign in (null on sign-out), from any flow, including the web button.
  Stream<String?> get idTokens;

  /// Silent sign-in of a returning user. Null when the platform answers later, through [idTokens].
  Future<String?>? restore();

  /// Whether [signIn] can be called; otherwise the platform shows its own button (web).
  bool get supportsSignInCall;

  /// Interactive sign-in (Android); the token also arrives on [idTokens].
  Future<String?> signIn();

  Future<void> signOut();
}

class GoogleSignInGateway implements GoogleAuthGateway {
  GoogleSignInGateway(this._config);

  final AppConfig _config;

  GoogleSignIn get _google => GoogleSignIn.instance;

  @override
  Future<void> initialize() => _google.initialize(
        clientId: kIsWeb ? _config.googleClientId : null,
        serverClientId: kIsWeb ? null : _config.googleClientId,
      );

  @override
  Stream<String?> get idTokens => _google.authenticationEvents.map(
        (event) => switch (event) {
          GoogleSignInAuthenticationEventSignIn(:final user) => user.authentication.idToken,
          GoogleSignInAuthenticationEventSignOut() => null,
        },
      );

  @override
  Future<String?>? restore() {
    final attempt = _google.attemptLightweightAuthentication();
    return attempt?.then((account) => account?.authentication.idToken);
  }

  @override
  bool get supportsSignInCall => _google.supportsAuthenticate();

  @override
  Future<String?> signIn() async => (await _google.authenticate()).authentication.idToken;

  @override
  Future<void> signOut() => _google.signOut();
}

final googleAuthGatewayProvider = Provider<GoogleAuthGateway>(
  (ref) => GoogleSignInGateway(ref.watch(appConfigProvider)),
);
