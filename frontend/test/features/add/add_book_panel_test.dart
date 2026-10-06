import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/add/add_book_panel.dart';
import 'package:library_app/features/add/scan_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

void main() {
  late FakeApi api;
  BookResponse? added;
  String? scanned;

  setUpAll(registerFallbacks);

  setUp(() {
    api = FakeApi();
    added = null;
    scanned = null;
    when(() => api.books.createBook(bookRequest: any(named: 'bookRequest')))
        .thenAnswer((call) async => ok(book(42, (call.namedArguments[#bookRequest] as BookRequest).title)));
    when(() => api.books.saveMyReading(id: any(named: 'id'), readingRequest: any(named: 'readingRequest')))
        .thenAnswer((_) async => ok(ReadingResponse(status: ReadingStatus.TO_READ)));
    when(() => api.categories.listCategories()).thenAnswer(
      (_) async => ok([CategoryResponse(id: 3, name: 'Classiques', color: '#3E6B48')]),
    );
  });

  void lookupAnswers(Object answer) {
    when(() => api.lookup.lookupIsbn(isbn: any(named: 'isbn'))).thenAnswer(
      (_) => answer is IsbnLookupResponse ? Future.value(ok(answer)) : Future.error(answer),
    );
  }

  Future<void> pumpPanel(WidgetTester tester, {String? isbn}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(
      tester,
      SingleChildScrollView(
        child: AddBookPanel(
          initialIsbn: isbn,
          onAdded: (book) => added = book,
          onScan: () async => scanned,
        ),
      ),
      overrides: [api.override],
    );
  }

  BookRequest created() =>
      verify(() => api.books.createBook(bookRequest: captureAny(named: 'bookRequest'))).captured.single as BookRequest;

  testWidgets('adds a book found by ISBN to the library with a status and categories', (tester) async {
    lookupAnswers(
      IsbnLookupResponse(
        isbn13: '9782253006305',
        source_: MetadataSource.OPEN_LIBRARY,
        title: 'Vingt mille lieues sous les mers',
        authors: 'Jules Verne',
        publisher: 'Le Livre de Poche',
        year: 1990,
      ),
    );
    await pumpPanel(tester);

    await tester.enterText(find.byType(TextField), '978-2-253-00630-5');
    await tester.tap(find.text('Chercher'));
    await tester.pumpAndSettle();

    expect(find.text('Trouvé sur Open Library'), findsOneWidget);
    expect(find.text('Le Livre de Poche · 1990'), findsOneWidget);
    await tester.tap(find.text('En cours'));
    await tester.tap(find.text('Classiques'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter à ma bibliothèque'));
    await tester.pumpAndSettle();

    final request = created();
    expect(request.isbn, '9782253006305');
    expect(request.title, 'Vingt mille lieues sous les mers');
    expect(request.owned, isTrue);
    expect(request.categoryIds, [3]);
    final reading = verify(
      () => api.books.saveMyReading(id: 42, readingRequest: captureAny(named: 'readingRequest')),
    ).captured.single as ReadingRequest;
    expect(reading.status, ReadingStatus.READING);
    expect(added?.id, 42);
  });

  testWidgets('adds a wish without reading status', (tester) async {
    lookupAnswers(IsbnLookupResponse(isbn13: '9782253006305', source_: MetadataSource.GOOGLE_BOOKS, title: 'Bel-Ami'));
    await pumpPanel(tester, isbn: '9782253006305');
    expect(find.text('Trouvé sur Google Books'), findsOneWidget);

    await tester.tap(find.text('Ma liste d\'envies'));
    await tester.pumpAndSettle();
    expect(find.text('Mon statut'), findsNothing);
    await tester.tap(find.text('Ajouter à ma liste d\'envies'));
    await tester.pumpAndSettle();

    expect(created().owned, isFalse);
    verifyNever(() => api.books.saveMyReading(id: any(named: 'id'), readingRequest: any(named: 'readingRequest')));
  });

  testWidgets('opens the form when no source knows the ISBN', (tester) async {
    lookupAnswers(httpError(404));
    await pumpPanel(tester, isbn: '9790000000001');

    expect(find.textContaining('Livre introuvable'), findsOneWidget);
    await tester.tap(find.text('Ajouter à ma bibliothèque'));
    await tester.pumpAndSettle();
    expect(find.text('Le titre est obligatoire.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Titre *'), 'Carnet de voyage');
    await tester.enterText(find.widgetWithText(TextField, 'Année'), '2019');
    await tester.tap(find.text('Ajouter à ma bibliothèque'));
    await tester.pumpAndSettle();

    final request = created();
    expect(request.isbn, '9790000000001');
    expect(request.title, 'Carnet de voyage');
    expect(request.year, 2019);
  });

  testWidgets('points to the book already in the library', (tester) async {
    lookupAnswers(
      IsbnLookupResponse(isbn13: '9782070612758', source_: MetadataSource.LIBRARY, existingBookId: 7, title: 'Le Petit Prince'),
    );
    await pumpPanel(tester, isbn: '9782070612758');

    expect(find.text('« Le Petit Prince » est déjà dans la bibliothèque.'), findsOneWidget);
    expect(find.text('Ajouter à ma bibliothèque'), findsNothing);
  });

  testWidgets('searches the scanned ISBN', (tester) async {
    lookupAnswers(IsbnLookupResponse(isbn13: '9782070612758', source_: MetadataSource.OPEN_LIBRARY, title: 'Le Petit Prince'));
    await pumpPanel(tester);
    scanned = '9782070612758';

    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();

    verify(() => api.lookup.lookupIsbn(isbn: '9782070612758')).called(1);
    expect(find.text('Le Petit Prince'), findsWidgets);
  });

  testWidgets('enters a book without ISBN', (tester) async {
    await pumpPanel(tester);

    await tester.tap(find.text('Pas d\'ISBN ? Saisie manuelle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Titre *'), 'Album de famille');
    await tester.tap(find.text('Ajouter à ma bibliothèque'));
    await tester.pumpAndSettle();

    expect(created().isbn, isNull);
  });

  test('recognises ISBN barcodes among EAN-13', () {
    expect(ScanScreen.isIsbn('9782070612758'), isTrue);
    expect(ScanScreen.isIsbn('9790000000001'), isTrue);
    expect(ScanScreen.isIsbn('3017620422003'), isFalse); // a jar of spread
    expect(ScanScreen.isIsbn('978207061275'), isFalse);
    expect(ScanScreen.isIsbn(null), isFalse);
  });
}
