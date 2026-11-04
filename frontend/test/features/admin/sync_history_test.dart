import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/admin/sync_history.dart';
import 'package:library_app/features/admin/sync_run_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

final _start = DateTime.utc(2026, 11, 4, 18, 0);

SyncRunResponse run(SyncRunState state,
        {int id = 1, SyncKind kind = SyncKind.METADATA_FILL, int total = 10, int processed = 0, int succeeded = 0}) =>
    SyncRunResponse(
      id: id,
      kind: kind,
      startedBy: kind == SyncKind.SERIES_SCHEDULED ? null : 'owner@example.com',
      state: state,
      total: total,
      processed: processed,
      succeeded: succeeded,
      unchanged: processed - succeeded,
      notFound: 0,
      failed: 0,
      startedAt: _start,
      finishedAt: state == SyncRunState.RUNNING ? null : _start.add(const Duration(minutes: 3, seconds: 12)),
    );

PageResponseSyncRunResponse runs(List<SyncRunResponse> items) =>
    PageResponseSyncRunResponse(items: items, page: 0, size: 20, totalItems: items.length, totalPages: 1);

PageResponseSyncRunItemResponse items(List<SyncRunItemResponse> items) =>
    PageResponseSyncRunItemResponse(items: items, page: 0, size: 50, totalItems: items.length, totalPages: 1);

SyncRunItemResponse item(int id, String label, SyncItemOutcome outcome, [String? detail]) =>
    SyncRunItemResponse(id: id, label: label, outcome: outcome, detail: detail, createdAt: _start);

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() => api = FakeApi());

  testWidgets('the history card follows a running synchronisation until it ends', (tester) async {
    var polls = 0;
    when(() => api.admin.listSyncRuns(page: any(named: 'page'))).thenAnswer((_) async {
      polls++;
      return ok(runs([
        polls == 1
            ? run(SyncRunState.RUNNING, processed: 4, succeeded: 1)
            : run(SyncRunState.DONE, processed: 10, succeeded: 3),
        run(SyncRunState.DONE, id: 2, kind: SyncKind.SERIES_SCHEDULED, total: 2, processed: 2, succeeded: 2),
      ]));
    });
    await pumpScreen(
      tester,
      const Scaffold(body: SingleChildScrollView(child: SyncHistoryCard(pollInterval: Duration(seconds: 1)))),
      overrides: [api.override],
    );

    expect(find.text('Resynchronisation des livres'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('4 / 10'), findsOneWidget);
    expect(find.text('Tomes des séries (automatique)'), findsOneWidget);
    expect(find.textContaining('automatique · en 3 min 12 s'), findsOneWidget);
    expect(find.text('2 trouvées à la BnF · 0 sans liste'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('En cours'), findsNothing);
    expect(find.text('3 complétés · 7 inchangés'), findsOneWidget);
  });

  testWidgets('a synchronisation shows what it did with each book, live', (tester) async {
    var polls = 0;
    when(() => api.admin.getSyncRun(id: 7)).thenAnswer((_) async {
      polls++;
      return ok(polls == 1
          ? run(SyncRunState.RUNNING, id: 7, processed: 1, succeeded: 1)
          : run(SyncRunState.DONE, id: 7, processed: 2, succeeded: 1));
    });
    when(() => api.admin.listSyncRunItems(id: 7, problemsOnly: false, page: 0)).thenAnswer((_) async => ok(items([
          if (polls > 1) item(2, 'Dune', SyncItemOutcome.FAILED, 'Open Library ne répond pas.'),
          item(1, 'L\'Étranger', SyncItemOutcome.UPDATED, 'Modifié : résumé'),
        ])));
    when(() => api.admin.listSyncRunItems(id: 7, problemsOnly: true, page: 0))
        .thenAnswer((_) async => ok(items([item(2, 'Dune', SyncItemOutcome.FAILED, 'Open Library ne répond pas.')])));

    await pumpScreen(tester, const SyncRunScreen(runId: 7, pollInterval: Duration(seconds: 1)),
        overrides: [api.override]);

    expect(find.text('1 / 10 livres traités'), findsOneWidget);
    expect(find.text('L\'Étranger'), findsOneWidget);
    expect(find.text('Modifié : résumé'), findsOneWidget);
    expect(find.text('Dune'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('2 livres traités'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Échec'), findsOneWidget);

    await tester.tap(find.text('Seulement les introuvables et les échecs'));
    await tester.pump();
    await tester.pump();
    expect(find.text('L\'Étranger'), findsNothing);
    expect(find.text('Dune'), findsOneWidget);
  });
}
