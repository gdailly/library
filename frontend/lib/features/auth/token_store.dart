import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage_stub.dart' if (dart.library.js_interop) 'token_storage_web.dart';

/// Keeps the Google ID token of the signed-in member between page reloads (web only: on Android, Google restores
/// the session silently). The token is used again only until it expires, about an hour after sign-in.
class TokenStore {
  TokenStore({TokenStorage? storage, DateTime Function()? now})
      : _storage = storage ?? createTokenStorage(),
        _now = now ?? DateTime.now;

  static const key = 'library.idToken';

  /// A token about to expire is not worth restoring: the first API call would be refused.
  static const margin = Duration(minutes: 2);

  final TokenStorage _storage;
  final DateTime Function() _now;

  /// The saved token while it is still valid; an expired or unreadable one is forgotten.
  String? read() {
    final token = _storage.read(key);
    if (token == null) {
      return null;
    }
    final expiry = expiryOf(token);
    if (expiry == null || !expiry.isAfter(_now().add(margin))) {
      _storage.remove(key);
      return null;
    }
    return token;
  }

  void save(String token) => _storage.write(key, token);

  void clear() => _storage.remove(key);

  /// The `exp` claim of a JWT, null when the token cannot be read.
  static DateTime? expiryOf(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = claims is Map ? claims['exp'] : null;
      return exp is num ? DateTime.fromMillisecondsSinceEpoch((exp * 1000).round(), isUtc: true) : null;
    } on FormatException {
      return null;
    }
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
