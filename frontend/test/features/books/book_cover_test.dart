import 'package:flutter_test/flutter_test.dart';
import 'package:library_api/library_api.dart';
import 'package:library_app/core/theme.dart';
import 'package:library_app/features/books/book_cover.dart';
import 'package:library_app/features/books/reading_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';

void main() {
  testWidgets('draws a cover with title and author when there is no image', (tester) async {
    await pumpScreen(tester, const Center(child: BookCover(title: 'Germinal', authors: 'Émile Zola', width: 120)));

    expect(find.text('Germinal'), findsOneWidget);
    expect(find.text('Émile Zola'), findsOneWidget);
    expect(find.bySemanticsLabel('Couverture de Germinal'), findsOneWidget);
    expect(tester.getSize(find.byType(BookCover)), const Size(120, 180));
  });

  test('gives a title always the same cover color', () {
    expect(BookCover.colorFor('Germinal'), BookCover.colorFor('Germinal'));
    expect(AppColors.covers, contains(BookCover.colorFor('Candide')));
  });

  test('summarises my reading under a book', () {
    expect(readingSummary(null), '');
    expect(readingSummary(ReadingResponse(status: ReadingStatus.READING)), 'En cours');
    expect(readingSummary(ReadingResponse(status: ReadingStatus.READ, rating: 3)), 'Lu · ★★★');
  });
}
