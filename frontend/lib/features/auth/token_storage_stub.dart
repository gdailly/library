/// Key-value storage of the token; nothing is kept outside the web.
class TokenStorage {
  String? read(String key) => null;

  void write(String key, String value) {}

  void remove(String key) {}
}

TokenStorage createTokenStorage() => TokenStorage();
