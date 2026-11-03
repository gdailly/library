import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../series/series_providers.dart';

/// Administration card that lists again, from the BnF, the volumes of every series without waiting for the
/// hourly background task.
class SeriesSyncCard extends ConsumerStatefulWidget {
  const SeriesSyncCard({super.key, required this.pollInterval});

  final Duration pollInterval;

  @override
  ConsumerState<SeriesSyncCard> createState() => _SeriesSyncCardState();
}

class _SeriesSyncCardState extends ConsumerState<SeriesSyncCard> {
  Timer? _poll;
  SeriesSyncJobResponse? _job;
  bool _busy = false;
  String? _error;

  AdminApi get _api => ref.read(libraryApiProvider).getAdminApi();

  @override
  void initState() {
    super.initState();
    _api.getSeriesSync().then((response) {
      if (mounted && response.data != null) {
        _follow(response.data!);
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _follow(SeriesSyncJobResponse job) {
    setState(() => _job = job);
    _poll?.cancel();
    if (job.state != SyncState.RUNNING) {
      return;
    }
    _poll = Timer.periodic(widget.pollInterval, (_) async {
      try {
        final status = (await _api.getSeriesSync()).data!;
        if (!mounted) {
          return;
        }
        setState(() => _job = status);
        if (status.state != SyncState.RUNNING) {
          _poll?.cancel();
          ref.invalidate(seriesListProvider);
        }
      } catch (_) {
        // Next tick retries.
      }
    });
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      _follow((await _api.startSeriesSync()).data!);
    } catch (e) {
      _error = errorMessage(e);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final running = job?.state == SyncState.RUNNING;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La liste complète des tomes de chaque série vient de la BnF. Elle est récupérée automatiquement '
          'toutes les heures et mise à jour tous les 30 jours ; tu peux la récupérer à nouveau pour toutes '
          'les séries maintenant. Pour une seule série, utilise « Resynchroniser la série » sur sa page.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (job != null && job.state != SyncState.IDLE) ...[
          Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  running
                      ? '${job.processed} / ${job.total} séries traitées'
                      : 'Terminé : ${job.processed} séries traitées',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: job.total == 0 ? 1.0 : job.processed / job.total,
                    minHeight: 8,
                    color: AppColors.accent,
                    backgroundColor: AppColors.accentLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    '${job.found} trouvée${job.found > 1 ? 's' : ''} à la BnF',
                    '${job.notFound} sans liste',
                    if (job.failed > 0) '${job.failed} en échec',
                  ].join(' · '),
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          onPressed: _busy || running ? null : _start,
          icon: const Icon(Icons.sync),
          label: Text(running ? 'Synchronisation en cours…' : 'Synchroniser toutes les séries'),
          style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
        ),
        if (_error != null) ...[const SizedBox(height: 16), MessageBox.error(_error!)],
      ],
    );
  }
}
