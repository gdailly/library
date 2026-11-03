import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../../shared/search_field.dart';
import '../books/book_cover.dart';
import 'series_labels.dart';
import 'series_providers.dart';

/// Séries: what the library has of each series and which volumes are missing.
class SeriesScreen extends ConsumerWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(seriesQueryProvider);
    final series = ref.watch(seriesListProvider(query));
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Séries', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  series.hasValue ? _count(series.requireValue.length) : ' ',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                SearchField(hint: 'Rechercher une série', onChanged: ref.read(seriesQueryProvider.notifier).search),
              ],
            ),
          ),
        ),
        ...switch (series) {
          AsyncValue(:final value?) when value.isEmpty => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      query.isEmpty
                          ? 'Aucune série pour l\'instant. La série et le tome viennent de la BnF à l\'ajout '
                              'ou à la resynchronisation, et se saisissent aussi sur la fiche d\'un livre.'
                          : 'Aucune série trouvée.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          AsyncValue(:final value?) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverList.separated(
                  itemCount: value.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => SeriesCard(series: value[index]),
                ),
              ),
            ],
          AsyncValue(:final error?) => [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: MessageBox.error(
                    errorMessage(error),
                    onRetry: () => ref.invalidate(seriesListProvider(query)),
                  ),
                ),
              ),
            ],
          _ => [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))],
        },
      ],
    );
  }

  static String _count(int count) => count <= 1 ? '$count série' : '$count séries';
}

/// One series: its cover, how many volumes the library owns and which are missing.
class SeriesCard extends StatelessWidget {
  const SeriesCard({super.key, required this.series});

  final SeriesResponse series;

  @override
  Widget build(BuildContext context) {
    final last = series.lastNumber;
    final complete = series.missingNumbers.isEmpty;
    final wishedMissing = series.missingNumbers.where(series.wishedNumbers.contains).toList();
    final otherMissing = series.missingNumbers.where((n) => !series.wishedNumbers.contains(n)).toList();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(seriesLocation(series.name)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(title: series.name, imageUrl: series.cover?.thumbUrl, width: 56, showText: false),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(series.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        last == null
                            ? albumCount(series.owned)
                            : '${series.ownedNumbers.length} tome${series.ownedNumbers.length > 1 ? 's' : ''} sur $last',
                        if (series.unnumbered > 0) '${series.unnumbered} sans numéro',
                      ].join(' · '),
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (series.catalogVolumes == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text('Liste des tomes BnF en cours de récupération',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    if (last != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: last == 0 ? 0 : series.ownedNumbers.length / last,
                          minHeight: 6,
                          color: AppColors.accent,
                          backgroundColor: AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (complete)
                        const Text('Complète jusqu\'au dernier tome connu',
                            style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600))
                      else ...[
                        if (otherMissing.isNotEmpty)
                          Text('Manque : ${volumeRanges(otherMissing)}', style: const TextStyle(fontSize: 13)),
                        if (wishedMissing.isNotEmpty)
                          Text('En envie : ${volumeRanges(wishedMissing)}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
