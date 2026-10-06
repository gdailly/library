import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings given at build time:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=GOOGLE_CLIENT_ID=<web client id>`
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.googleClientId});

  factory AppConfig.fromEnvironment() => const AppConfig(
        apiBaseUrl: String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8080',
        ),
        googleClientId: String.fromEnvironment('GOOGLE_CLIENT_ID'),
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
}

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());
