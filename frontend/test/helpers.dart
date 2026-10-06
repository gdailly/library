import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/core/api.dart';
import 'package:library_app/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockLibraryApi extends Mock implements LibraryApi {}

class MockBooksApi extends Mock implements BooksApi {}

class MockMeApi extends Mock implements MeApi {}

class MockLookupApi extends Mock implements LookupApi {}

class MockCategoriesApi extends Mock implements CategoriesApi {}

class MockMembersApi extends Mock implements MembersApi {}

/// The generated API, with each tag's client replaced by a mock.
class FakeApi {
  FakeApi() {
    when(() => library.getBooksApi()).thenReturn(books);
    when(() => library.getMeApi()).thenReturn(me);
    when(() => library.getLookupApi()).thenReturn(lookup);
    when(() => library.getCategoriesApi()).thenReturn(categories);
    when(() => library.getMembersApi()).thenReturn(members);
    when(() => categories.listCategories()).thenAnswer((_) async => ok(<CategoryResponse>[]));
  }

  final library = MockLibraryApi();
  final books = MockBooksApi();
  final me = MockMeApi();
  final lookup = MockLookupApi();
  final categories = MockCategoriesApi();
  final members = MockMembersApi();

  Override get override => libraryApiProvider.overrideWithValue(library);
}

Response<T> ok<T>(T data) => Response<T>(data: data, statusCode: 200, requestOptions: RequestOptions());

DioException httpError(int status, {String? detail}) {
  final request = RequestOptions();
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object>(
      requestOptions: request,
      statusCode: status,
      data: detail == null ? null : {'status': status, 'detail': detail},
    ),
  );
}

BookResponse book(
  int id,
  String title, {
  String? authors,
  ReadingResponse? reading,
  List<CategoryResponse> categories = const [],
}) =>
    BookResponse(
      id: id,
      title: title,
      authors: authors,
      owned: true,
      createdAt: DateTime(2026, 10, 1),
      categories: categories,
      myReading: reading,
      otherReadings: const [],
    );

PageResponseBookResponse page(List<BookResponse> items) =>
    PageResponseBookResponse(items: items, page: 0, size: 50, totalItems: items.length, totalPages: 1);

/// [child] in the app theme (without downloaded fonts) and a Riverpod scope.
Future<void> pumpScreen(WidgetTester tester, Widget child, {List<Override> overrides = const []}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: overrides,
      child: MaterialApp(theme: buildTheme(googleFonts: false), home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

void registerFallbacks() {
  registerFallbackValue(ReadingRequest(status: ReadingStatus.TO_READ));
  registerFallbackValue(BookRequest(title: ''));
  registerFallbackValue(MemberRequest(email: ''));
  registerFallbackValue(CategoryRequest(name: '', color: ''));
}
