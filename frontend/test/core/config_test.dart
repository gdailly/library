import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/core/config.dart';

void main() {
  group('AppConfig.defaultApiBaseUrl', () {
    test('keeps the configured URL without its trailing slash', () {
      expect(AppConfig.defaultApiBaseUrl('https://livre.example.org/', isWeb: false), 'https://livre.example.org');
      expect(AppConfig.defaultApiBaseUrl('http://192.168.1.20', isWeb: true, webOrigin: 'http://x'),
          'http://192.168.1.20');
    });

    test('uses the page origin on the web when nothing is configured', () {
      expect(AppConfig.defaultApiBaseUrl('', isWeb: true, webOrigin: 'https://livre.example.org'),
          'https://livre.example.org');
    });

    test('falls back to the local backend elsewhere', () {
      expect(AppConfig.defaultApiBaseUrl('', isWeb: false), 'http://localhost:8080');
    });
  });
}
