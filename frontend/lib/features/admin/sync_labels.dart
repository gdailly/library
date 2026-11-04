import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';

/// What a synchronisation of the history did, in the words of the administration page.
String syncKindLabel(SyncKind kind) => switch (kind) {
      SyncKind.METADATA_FILL => 'Resynchronisation des livres',
      SyncKind.METADATA_FETCH => 'Récupération des sources',
      SyncKind.METADATA_BOOK => 'Resynchronisation d\'un livre',
      SyncKind.SERIES_ALL => 'Synchronisation des séries',
      SyncKind.SERIES_SCHEDULED => 'Tomes des séries (automatique)',
      SyncKind.SERIES_ONE => 'Synchronisation d\'une série',
    };

/// Whether the items of a synchronisation are books or series.
bool syncOnSeries(SyncKind kind) =>
    kind == SyncKind.SERIES_ALL || kind == SyncKind.SERIES_SCHEDULED || kind == SyncKind.SERIES_ONE;

IconData syncKindIcon(SyncKind kind) => syncOnSeries(kind) ? Icons.collections_bookmark_outlined : Icons.menu_book_outlined;

String syncStateLabel(SyncRunState state) => switch (state) {
      SyncRunState.RUNNING => 'En cours',
      SyncRunState.DONE => 'Terminée',
      SyncRunState.INTERRUPTED => 'Interrompue',
    };

/// Counters of a synchronisation: "12 complétés · 80 inchangés · 2 introuvables".
String syncCounts(SyncRunResponse run) {
  String plural(int n, String word) => '$n $word${n > 1 ? 's' : ''}';
  if (syncOnSeries(run.kind)) {
    return [
      '${plural(run.succeeded, 'trouvée')} à la BnF',
      '${run.notFound} sans liste',
      if (run.failed > 0) '${run.failed} en échec',
    ].join(' · ');
  }
  return [
    plural(run.succeeded, run.kind == SyncKind.METADATA_FETCH ? 'modifié' : 'complété'),
    plural(run.unchanged, 'inchangé'),
    if (run.notFound > 0) plural(run.notFound, 'introuvable'),
    if (run.failed > 0) '${run.failed} en échec',
  ].join(' · ');
}

String syncOutcomeLabel(SyncItemOutcome outcome) => switch (outcome) {
      SyncItemOutcome.UPDATED => 'Modifié',
      SyncItemOutcome.UNCHANGED => 'Inchangé',
      SyncItemOutcome.FOUND => 'Trouvée',
      SyncItemOutcome.NOT_FOUND => 'Introuvable',
      SyncItemOutcome.NO_REFERENCE => 'Sans notice',
      SyncItemOutcome.FAILED => 'Échec',
    };

/// Foreground and background of an outcome's tag.
(Color, Color) syncOutcomeColors(SyncItemOutcome outcome) => switch (outcome) {
      SyncItemOutcome.UPDATED || SyncItemOutcome.FOUND => (AppColors.accent, AppColors.accentLight),
      SyncItemOutcome.FAILED => (AppColors.error, AppColors.errorBackground),
      _ => (AppColors.textSecondary, AppColors.chipBackground),
    };

/// "04/11/2026 à 21:05", in local time.
String dateTimeLabel(DateTime date) {
  final local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} à ${two(local.hour)}:${two(local.minute)}';
}

/// "3 min 12 s", "1 h 05 min".
String durationLabel(Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) {
    return '$seconds s';
  }
  if (seconds < 3600) {
    return '${seconds ~/ 60} min ${(seconds % 60).toString().padLeft(2, '0')} s';
  }
  return '${seconds ~/ 3600} h ${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')} min';
}

/// When a synchronisation started, who started it and how long it took.
String syncWhen(SyncRunResponse run) {
  final parts = [
    dateTimeLabel(run.startedAt),
    run.startedBy ?? 'automatique',
    if (run.finishedAt != null) 'en ${durationLabel(run.finishedAt!.difference(run.startedAt))}',
  ];
  return parts.join(' · ');
}

/// Small coloured tag (state of a synchronisation, outcome of an item).
class SyncTag extends StatelessWidget {
  const SyncTag(this.label, {super.key, required this.foreground, required this.background});

  factory SyncTag.state(SyncRunState state) => switch (state) {
        SyncRunState.RUNNING => SyncTag(syncStateLabel(state), foreground: AppColors.accent, background: AppColors.accentLight),
        SyncRunState.INTERRUPTED => SyncTag(syncStateLabel(state), foreground: AppColors.error, background: AppColors.errorBackground),
        _ => SyncTag(syncStateLabel(state), foreground: AppColors.textSecondary, background: AppColors.chipBackground),
      };

  factory SyncTag.outcome(SyncItemOutcome outcome) {
    final (foreground, background) = syncOutcomeColors(outcome);
    return SyncTag(syncOutcomeLabel(outcome), foreground: foreground, background: background);
  }

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}

/// Progress bar of a synchronisation, full once it ended.
class SyncProgressBar extends StatelessWidget {
  const SyncProgressBar({super.key, required this.run});

  final SyncRunResponse run;

  @override
  Widget build(BuildContext context) {
    final ratio = run.total == 0 || run.state != SyncRunState.RUNNING ? 1.0 : run.processed / run.total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 6,
        color: run.state == SyncRunState.INTERRUPTED ? AppColors.error : AppColors.accent,
        backgroundColor: AppColors.accentLight,
      ),
    );
  }
}
