import 'package:web/web.dart' as web;

import 'token_storage_stub.dart' as stub;

/// The browser's local storage; a blocked storage (private browsing, policies) behaves as empty.
class _LocalTokenStorage implements stub.TokenStorage {
  @override
  String? read(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  void write(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (_) {
      // Not kept: the next reload shows the sign-in screen.
    }
  }

  @override
  void remove(String key) {
    try {
      web.window.localStorage.removeItem(key);
    } catch (_) {}
  }
}

typedef TokenStorage = stub.TokenStorage;

stub.TokenStorage createTokenStorage() => _LocalTokenStorage();
