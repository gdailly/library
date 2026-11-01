import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/admin/admin_screen.dart';
import 'package:library_app/features/admin/book_sync_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

MetadataSyncJobResponse job(SyncState state, {int total = 0, int processed = 0, int updated = 0, int notFound = 0}) =>
    MetadataSyncJobResponse(
      state: state,
      total: total,
      processed: processed,
      updated: updated,
      unchanged: processed - updated - notFound,
      notFound: notFound,
      failed: 0,
    );

MetadataAdminResponse overview({MetadataSyncJobResponse? syncJob, int notFound = 4}) => MetadataAdminResponse(
      books: 120,
      booksWithIsbn: 110,
      cachedIsbns: 115,
      cachedNotFound: notFound,
      job: syncJob ?? job(SyncState.IDLE),
    );

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() {
    api = FakeApi();
    when(() => api.admin.getMetadataAdmin()).thenAnswer((_) async => ok(overview()));
  });

  Future<void> pumpAdmin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, const AdminScreen(pollInterval: Duration(milliseconds: 10)), overrides: [api.override]);
  }

  testWidgets('shows the books and the ISBN cache', (tester) async {
    await pumpAdmin(tester);

    expect(find.text('120 livres, dont 110 avec un ISBN.'), findsOneWidget);
    expect(find.textContaining('115 ISBN, dont 4 introuvables'), findsOneWidget);
  });

  testWidgets('starts the full resynchronisation and follows it to the end', (tester) async {
    when(() => api.admin.startMetadataSync()).thenAnswer((_) async => ok(job(SyncState.RUNNING, total: 110)));
    var polls = 0;
    when(() => api.admin.getMetadataSync()).thenAnswer((_) async {
      polls++;
      return ok(polls == 1
          ? job(SyncState.RUNNING, total: 110, processed: 40, updated: 12)
          : job(SyncState.DONE, total: 110, processed: 110, updated: 30, notFound: 2));
    });
    await pumpAdmin(tester);

    await tester.tap(find.text('Lancer la resynchronisation'));
    await tester.pump();
    expect(find.text('0 / 110 livres traités'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 15));
    await tester.pump();
    expect(find.text('40 / 110 livres traités'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 15));
    await tester.pumpAndSettle();
    expect(find.text('Terminé : 110 livres traités'), findsOneWidget);
    expect(find.text('30 complétés · 78 inchangés · 2 introuvables'), findsOneWidget);
  });

  testWidgets('forgets the ISBN remembered as not found', (tester) async {
    when(() => api.admin.clearIsbnCache(scope: CacheScope.NOT_FOUND))
        .thenAnswer((_) async => ok(CacheClearResponse(deleted: 4)));
    await pumpAdmin(tester);

    await tester.tap(find.text('Oublier les ISBN introuvables'));
    await tester.pumpAndSettle();

    expect(find.text('4 entrées supprimées du cache.'), findsOneWidget);
    verify(() => api.admin.clearIsbnCache(scope: CacheScope.NOT_FOUND)).called(1);
  });

  testWidgets('asks before emptying the whole cache', (tester) async {
    await pumpAdmin(tester);

    await tester.tap(find.text('Vider tout le cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    verifyNever(() => api.admin.clearIsbnCache(scope: any(named: 'scope')));
  });

  test('summarises a book resynchronisation in French', () {
    BookSyncResponse result(SyncOutcome outcome, List<String> fields) =>
        BookSyncResponse(outcome: outcome, changedFields: fields, book: book(1, 'L\'Étranger'));

    expect(syncSummary(result(SyncOutcome.UPDATED, ['authors', 'summary', 'cover'])),
        'Mis à jour : auteurs, résumé, couverture.');
    expect(syncSummary(result(SyncOutcome.NOT_FOUND, [])), 'Aucune source ne connaît cet ISBN.');
    expect(syncSummary(result(SyncOutcome.UNCHANGED, [])), 'Rien à mettre à jour : le livre est déjà à jour.');
  });
}
