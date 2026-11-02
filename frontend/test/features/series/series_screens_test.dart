import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/features/series/series_detail_screen.dart';
import 'package:library_app/features/series/series_labels.dart';
import 'package:library_app/features/series/series_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers.dart';

void main() {
  late FakeApi api;

  setUpAll(registerFallbacks);

  setUp(() => api = FakeApi());

  test('writes volume numbers in short', () {
    expect(volumeRanges([7, 1, 2, 3, 5, 8]), '1 à 3, 5, 7, 8');
    expect(volumeRanges([]), '');
    expect(seriesLabel('Tintin', 3), 'Tintin · tome 3');
    expect(seriesLabel('Tintin', null), 'Tintin');
    expect(seriesLocation('Les 4 As'), '/series/books?name=Les+4+As');
  });

  testWidgets('lists each series with what is owned and what is missing', (tester) async {
    when(() => api.series.listSeries(q: any(named: 'q'))).thenAnswer(
      (_) async => ok([
        SeriesResponse(
          name: 'Une aventure d\'Astérix',
          books: 4,
          owned: 3,
          ownedNumbers: const [1, 2, 3],
          wishedNumbers: const [6],
          missingNumbers: const [4, 5, 6],
          lastNumber: 6,
          unnumbered: 0,
        ),
        SeriesResponse(
          name: 'Blake et Mortimer',
          books: 2,
          owned: 2,
          ownedNumbers: const [1, 2],
          wishedNumbers: const [],
          missingNumbers: const [],
          lastNumber: 2,
          unnumbered: 0,
        ),
      ]),
    );

    await pumpScreen(tester, const SeriesScreen(), overrides: [api.override]);

    expect(find.text('2 séries'), findsOneWidget);
    expect(find.text('3 tomes sur 6'), findsOneWidget);
    expect(find.text('Manque : 4, 5'), findsOneWidget);
    expect(find.text('En envie : 6'), findsOneWidget);
    expect(find.text('Complète jusqu\'au dernier tome connu'), findsOneWidget);
  });

  testWidgets('shows a series volume by volume, with the missing ones', (tester) async {
    when(() => api.series.listSeriesBooks(name: 'Tintin')).thenAnswer(
      (_) async => ok([
        BookResponse(
          id: 1,
          title: 'Tintin au Congo',
          series: 'Tintin',
          seriesNumber: 2,
          owned: true,
          createdAt: DateTime(2026, 10, 1),
          categories: const [],
          otherReadings: const [],
        ),
        BookResponse(
          id: 2,
          title: 'Le Lotus bleu',
          series: 'Tintin',
          seriesNumber: 4,
          owned: false,
          createdAt: DateTime(2026, 10, 1),
          categories: const [],
          otherReadings: const [],
        ),
      ]),
    );

    await pumpScreen(tester, const SeriesDetailScreen(name: 'Tintin'), overrides: [api.override]);

    expect(find.text('1 tome sur 4 dans la bibliothèque · manque 1, 3, 4'), findsOneWidget);
    expect(find.text('Tome 2 · Tintin au Congo'), findsOneWidget);
    expect(find.text('Tome 4 · Le Lotus bleu'), findsOneWidget);
    expect(find.text('Dans la liste d\'envies'), findsOneWidget);
    expect(find.text('Manquant'), findsNWidgets(2));
  });
}
