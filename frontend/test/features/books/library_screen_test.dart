import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/books/library_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

void main() {
  late FakeApi api;

  void listAnswers(PageResponseBookResponse Function(Invocation call) answer) {
    when(
      () => api.books.listBooks(
        owned: any(named: 'owned'),
        q: any(named: 'q'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((call) async => ok(answer(call)));
  }

  setUp(() => api = FakeApi());

  testWidgets('shows the books of the library with my reading', (tester) async {
    listAnswers(
      (_) => page([
        book(1, 'Germinal', authors: 'Émile Zola', reading: ReadingResponse(status: ReadingStatus.READ, rating: 5)),
        book(2, 'Candide', authors: 'Voltaire'),
      ]),
    );

    await pumpScreen(tester, const LibraryScreen(), overrides: [api.override]);

    expect(find.text('2 livres'), findsOneWidget);
    expect(find.text('Lu · ★★★★★'), findsOneWidget);
    // Drawn cover and caption both show the title.
    expect(find.text('Candide'), findsNWidgets(2));
    verify(() => api.books.listBooks(owned: true, q: null, status: null)).called(1);
  });

  testWidgets('filters on my reading status', (tester) async {
    listAnswers((call) => page([if (call.namedArguments[#status] == ReadingStatus.READING) book(3, 'Nana')]));
    await pumpScreen(tester, const LibraryScreen(), overrides: [api.override]);
    expect(find.text('Aucun livre pour l\'instant.'), findsOneWidget);

    await tester.tap(find.text('En cours'));
    await tester.pumpAndSettle();

    expect(find.text('1 livre'), findsOneWidget);
    verify(() => api.books.listBooks(owned: true, q: null, status: ReadingStatus.READING)).called(1);
  });

  testWidgets('searches after the user stops typing', (tester) async {
    listAnswers((_) => page([]));
    await pumpScreen(tester, const LibraryScreen(), overrides: [api.override]);

    await tester.enterText(find.byType(TextField), '  zola ');
    await tester.pump(const Duration(milliseconds: 100));
    verifyNever(() => api.books.listBooks(owned: true, q: 'zola', status: null));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    verify(() => api.books.listBooks(owned: true, q: 'zola', status: null)).called(1);
    expect(find.text('Aucun livre trouvé.'), findsOneWidget);
  });

  testWidgets('switches to the list view', (tester) async {
    listAnswers((_) => page([book(1, 'Germinal', authors: 'Émile Zola')]));
    await pumpScreen(tester, const LibraryScreen(), overrides: [api.override]);
    expect(find.byType(ListTile), findsNothing);

    await tester.tap(find.byTooltip('Liste'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Émile Zola'), findsOneWidget);
  });

  testWidgets('offers to retry when the API fails', (tester) async {
    var calls = 0;
    when(
      () => api.books.listBooks(owned: any(named: 'owned'), q: any(named: 'q'), status: any(named: 'status')),
    ).thenAnswer((_) async {
      if (calls++ == 0) {
        throw httpError(500, detail: 'Base indisponible');
      }
      return ok(page([book(1, 'Germinal')]));
    });
    await pumpScreen(tester, const LibraryScreen(), overrides: [api.override]);
    expect(find.text('Base indisponible'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('1 livre'), findsOneWidget);
  });
}
