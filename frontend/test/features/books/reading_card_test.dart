import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/books/book_detail_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() {
    api = FakeApi();
    when(() => api.books.saveMyReading(id: any(named: 'id'), readingRequest: any(named: 'readingRequest')))
        .thenAnswer((call) async => ok(ReadingResponse(status: ReadingStatus.READ)));
    when(() => api.books.getBook(id: any(named: 'id'))).thenAnswer((_) async => ok(book(7, 'Germinal')));
  });

  ReadingRequest saved() => verify(
        () => api.books.saveMyReading(id: 7, readingRequest: captureAny(named: 'readingRequest')),
      ).captured.last as ReadingRequest;

  Future<void> pumpCard(WidgetTester tester, BookResponse book) =>
      pumpScreen(tester, SingleChildScrollView(child: ReadingCard(book: book)), overrides: [api.override]);

  testWidgets('saves the chosen status', (tester) async {
    await pumpCard(tester, book(7, 'Germinal'));

    await tester.tap(find.text('En cours'));
    await tester.pumpAndSettle();

    expect(saved().status, ReadingStatus.READING);
  });

  testWidgets('saves a rating with the current status and clears it on a second tap', (tester) async {
    await pumpCard(tester, book(7, 'Germinal', reading: ReadingResponse(status: ReadingStatus.READ, review: 'Fort')));

    await tester.tap(find.byTooltip('4 sur 5'));
    await tester.pumpAndSettle();
    final rated = saved();
    expect(rated.rating, 4);
    expect(rated.status, ReadingStatus.READ);
    expect(rated.review, 'Fort');
    expect(find.text('4 / 5'), findsOneWidget);

    await tester.tap(find.byTooltip('4 sur 5'));
    await tester.pumpAndSettle();
    expect(saved().rating, isNull);
    expect(find.text('Pas de note'), findsOneWidget);
  });

  testWidgets('asks for a status before a rating', (tester) async {
    await pumpCard(tester, book(7, 'Germinal'));

    await tester.tap(find.byTooltip('5 sur 5'));
    await tester.pumpAndSettle();

    expect(find.text('Choisis d\'abord un statut de lecture.'), findsOneWidget);
    verifyNever(() => api.books.saveMyReading(id: any(named: 'id'), readingRequest: any(named: 'readingRequest')));
  });

  testWidgets('shows reading dates and API errors', (tester) async {
    when(() => api.books.saveMyReading(id: any(named: 'id'), readingRequest: any(named: 'readingRequest')))
        .thenThrow(httpError(400, detail: 'La date de fin précède la date de début.'));
    await pumpCard(
      tester,
      book(
        7,
        'Germinal',
        reading: ReadingResponse(
          status: ReadingStatus.READ,
          startedOn: DateTime(2026, 8, 12),
          finishedOn: DateTime(2026, 8, 28),
        ),
      ),
    );
    expect(find.text('Lu du 12/08/2026 au 28/08/2026'), findsOneWidget);

    await tester.tap(find.text('Abandonné'));
    await tester.pumpAndSettle();

    expect(find.text('La date de fin précède la date de début.'), findsOneWidget);
  });
}
