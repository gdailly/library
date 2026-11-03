import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../../core/api.dart';

/// Text typed in the series search.
class SeriesQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void search(String text) => state = text.trim();
}

final seriesQueryProvider = NotifierProvider<SeriesQueryNotifier, String>(SeriesQueryNotifier.new);

/// The series of the library whose name contains [q].
final seriesListProvider = FutureProvider.family<List<SeriesResponse>, String>((ref, q) async {
  final response = await ref.watch(libraryApiProvider).getSeriesApi().listSeries(q: q.isEmpty ? null : q);
  return response.data!.toList();
});

/// One series volume by volume, including the volumes the library does not hold.
final seriesVolumesProvider = FutureProvider.autoDispose.family<SeriesDetailResponse, String>((ref, name) async {
  final response = await ref.watch(libraryApiProvider).getSeriesApi().getSeriesVolumes(name: name);
  return response.data!;
});
