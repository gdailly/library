import 'package:library_api/library_api.dart';

/// French labels of the reading statuses, in the order of the mock-ups.
const readingStatusLabels = {
  ReadingStatus.TO_READ: 'À lire',
  ReadingStatus.READING: 'En cours',
  ReadingStatus.READ: 'Lu',
  ReadingStatus.ABANDONED: 'Abandonné',
};

/// "Lu · ★★★★" under a book, empty when the user has no reading.
String readingSummary(ReadingResponse? reading) {
  if (reading == null) {
    return '';
  }
  final label = readingStatusLabels[reading.status] ?? '';
  final rating = reading.rating;
  return rating == null ? label : '$label · ${'★' * rating}';
}
