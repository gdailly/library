import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings given at build time:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=GOOGLE_CLIENT_ID=<web client id>`
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.googleClientId});

  factory AppConfig.fromEnvironment() => AppConfig(
        apiBaseUrl: defaultApiBaseUrl(
          const String.fromEnvironment('API_BASE_URL'),
          isWeb: kIsWeb,
          webOrigin: kIsWeb ? Uri.base.origin : null,
        ),
        googleClientId: const String.fromEnvironment('GOOGLE_CLIENT_ID'),
      );

  /// Root of the backend, without trailing slash.
  final String apiBaseUrl;

  /// OAuth client ID of the web application. The web app signs in with it;
  /// Android asks Google for an ID token issued to it (server client ID), so the
  /// backend sees the same audience on both platforms.
  final String googleClientId;

  bool get hasGoogleClientId => googleClientId.isNotEmpty;

  /// Absolute URL of a path returned by the API, such as a signed cover URL.
  String resolve(String path) => path.startsWith('http') ? path : '$apiBaseUrl$path';

  /// Backend root when `API_BASE_URL` is not given: the web app built for production is served
  /// by the same reverse proxy as the API, so it calls its own origin; elsewhere, the local backend.
  @visibleForTesting
  static String defaultApiBaseUrl(String configured, {required bool isWeb, String? webOrigin}) {
    final url = configured.trim();
    if (url.isNotEmpty) {
      return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    }
    return isWeb && webOrigin != null ? webOrigin : 'http://localhost:8080';
  }
}

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());
