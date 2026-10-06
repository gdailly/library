import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../features/auth/auth_controller.dart';
import 'config.dart';

/// HTTP client of the API: adds the Google ID token and signs the user out when the API rejects it.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authControllerProvider).idToken;
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          ref.read(authControllerProvider.notifier).sessionExpired();
        }
        handler.next(error);
      },
    ),
  );
  return dio;
});

/// Generated client (packages/library_api), one API class per tag.
final libraryApiProvider = Provider<LibraryApi>((ref) => LibraryApi(dio: ref.watch(dioProvider)));

/// French message for an API failure, from its ProblemDetail when the server sent one.
String errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Serveur injoignable. Vérifie ta connexion.',
      _ => 'Erreur du serveur (${error.response?.statusCode ?? '?'}).',
    };
  }
  return 'Erreur inattendue.';
}
