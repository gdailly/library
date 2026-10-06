import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/books/wishlist_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() {
    api = FakeApi();
    when(() => api.books.listBooks(owned: any(named: 'owned'), q: any(named: 'q'), status: any(named: 'status')))
        .thenAnswer(
      (_) async => ok(
        page([
          BookResponse(
            id: 4,
            title: 'Bel-Ami',
            authors: 'Guy de Maupassant',
            owned: false,
            addedByName: 'Claire',
            createdAt: DateTime(2026, 9, 28),
            categories: [CategoryResponse(id: 3, name: 'Classiques', color: '#3E6B48')],
            otherReadings: const [],
          ),
        ]),
      ),
    );
    when(() => api.books.updateBook(id: any(named: 'id'), bookRequest: any(named: 'bookRequest')))
        .thenAnswer((_) async => ok(book(4, 'Bel-Ami')));
  });

  testWidgets('lists the shared wishes with who added them', (tester) async {
    await pumpScreen(tester, const WishlistScreen(), overrides: [api.override]);

    expect(find.text('1 envie'), findsOneWidget);
    expect(find.text('Ajouté par Claire'), findsOneWidget);
    verify(() => api.books.listBooks(owned: false, q: null, status: null)).called(1);
  });

  testWidgets('moves a wish to the library, keeping its information', (tester) async {
    await pumpScreen(tester, const WishlistScreen(), overrides: [api.override]);

    await tester.tap(find.text('Je l\'ai'));
    await tester.pumpAndSettle();

    final request = verify(
      () => api.books.updateBook(id: 4, bookRequest: captureAny(named: 'bookRequest')),
    ).captured.single as BookRequest;
    expect(request.owned, isTrue);
    expect(request.authors, 'Guy de Maupassant');
    expect(request.categoryIds, [3]);
    expect(find.text('« Bel-Ami » est dans ta bibliothèque.'), findsOneWidget);
  });
}
