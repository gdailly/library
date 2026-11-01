import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/admin/metadata_book_screen.dart';
import 'package:library_app/features/admin/metadata_books_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

SourceMetadataResponse answer(MetadataSource? source, String title, {String? publisher, String? summary}) =>
    SourceMetadataResponse(source_: source, title: title, publisher: publisher, summary: summary);

BookMetadataResponse metadata() => BookMetadataResponse(
      book: book(5, 'L\'étranger', authors: 'Albert Camus'),
      fetchedAt: DateTime.utc(2026, 11, 1, 20),
      notFound: false,
      sources: [
        answer(MetadataSource.BNF, 'L\'Étranger', publisher: 'Gallimard'),
        answer(MetadataSource.GOOGLE_BOOKS, 'The Stranger', summary: 'Aujourd\'hui, maman est morte.'),
      ],
      merged: answer(null, 'L\'Étranger', publisher: 'Gallimard', summary: 'Aujourd\'hui, maman est morte.'),
      differences: const ['title', 'publisher', 'summary'],
    );

void main() {
  late FakeApi api;

  setUpAll(() {
    registerFallbacks();
    registerFallbackValue(ApplyMetadataRequest(source_: MetadataSource.BNF, fields: const []));
  });

  setUp(() {
    api = FakeApi();
    when(() => api.admin.getBookMetadata(id: 5)).thenAnswer((_) async => ok(metadata()));
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, screen, overrides: [api.override]);
  }

  testWidgets('shows each source beside the book', (tester) async {
    await pump(tester, const MetadataBookScreen(bookId: 5));

    expect(find.text('The Stranger'), findsOneWidget);
    expect(find.text('Gallimard'), findsNWidgets(2)); // fusion and BnF
    expect(find.text('Récupérer BnF'), findsOneWidget);
  });

  testWidgets('copies one field of a source into the book', (tester) async {
    when(() => api.admin.applyBookMetadata(id: 5, applyMetadataRequest: any(named: 'applyMetadataRequest')))
        .thenAnswer((_) async => ok(metadata()));
    await pump(tester, const MetadataBookScreen(bookId: 5));

    // The first "Utiliser" is the BnF title.
    await tester.tap(find.text('Utiliser').first);
    await tester.pumpAndSettle();

    final request = verify(
      () => api.admin.applyBookMetadata(id: 5, applyMetadataRequest: captureAny(named: 'applyMetadataRequest')),
    ).captured.single as ApplyMetadataRequest;
    expect(request.source_, MetadataSource.BNF);
    expect(request.fields, ['title']);
    expect(find.text('Repris de BnF : titre.'), findsOneWidget);
  });

  testWidgets('queries one source again', (tester) async {
    when(() => api.admin.syncBookMetadata(id: 5, mode: SyncMode.FETCH, source_: MetadataSource.GOOGLE_BOOKS))
        .thenAnswer((_) async => ok(BookSyncResponse(outcome: SyncOutcome.UNCHANGED, changedFields: const [], book: metadata().book)));
    await pump(tester, const MetadataBookScreen(bookId: 5));

    await tester.tap(find.text('Récupérer Google Books'));
    await tester.pumpAndSettle();

    expect(find.text('Données de Google Books récupérées.'), findsOneWidget);
  });

  testWidgets('lists the books whose sources disagree', (tester) async {
    when(() => api.admin.listBookMetadata(q: null, onlyDifferences: true, page: 0)).thenAnswer(
      (_) async => ok(PageResponseBookMetadataSummary(
        items: [
          BookMetadataSummary(
            id: 5,
            title: 'L\'étranger',
            isbn13: '9782070360024',
            hasCover: false,
            sources: const [MetadataSource.BNF, MetadataSource.GOOGLE_BOOKS],
            notFound: false,
            fetchedAt: DateTime.utc(2026, 11, 1),
            differences: const ['title', 'summary'],
          ),
        ],
        page: 0,
        size: 50,
        totalItems: 1,
        totalPages: 1,
      )),
    );
    await pump(tester, const MetadataBooksScreen());

    expect(find.text('L\'étranger'), findsOneWidget);
    expect(find.textContaining('BnF · Google Books'), findsOneWidget);
    expect(find.textContaining('Diffère : Titre, Résumé'), findsOneWidget);
  });
}
