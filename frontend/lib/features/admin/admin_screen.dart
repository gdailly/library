import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../books/books_providers.dart';
import 'series_sync_card.dart';
import 'sync_history.dart';

/// Overview of the metadata administration: books, ISBN cache and the full resynchronisation.
final metadataAdminProvider = FutureProvider.autoDispose<MetadataAdminResponse>((ref) async {
  final response = await ref.watch(libraryApiProvider).getAdminApi().getMetadataAdmin();
  return response.data!;
});

/// Administration (the application's administrator only): resynchronises the books with Open Library, Google Books and the BnF,
/// and empties the ISBN cache.
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key, this.pollInterval = const Duration(seconds: 2)});

  /// How often the progress of a running resynchronisation is read.
  final Duration pollInterval;

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  Timer? _poll;
  MetadataSyncJobResponse? _job;
  bool _busy = false;
  String? _error;
  String? _info;

  final _history = GlobalKey<SyncHistoryCardState>();

  AdminApi get _api => ref.read(libraryApiProvider).getAdminApi();

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// Follows a running job until it ends, then refreshes the counters and the book lists.
  void _follow(MetadataSyncJobResponse job) {
    setState(() => _job = job);
    _poll?.cancel();
    if (job.state != SyncState.RUNNING) {
      return;
    }
    _poll = Timer.periodic(widget.pollInterval, (_) async {
      try {
        final status = (await _api.getMetadataSync()).data!;
        if (!mounted) {
          return;
        }
        setState(() => _job = status);
        if (status.state != SyncState.RUNNING) {
          _poll?.cancel();
          ref
            ..invalidate(metadataAdminProvider)
            ..invalidate(booksProvider);
        }
      } catch (_) {
        // Next tick retries; the page shows the last known progress meanwhile.
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      _error = errorMessage(e);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _startSync(SyncMode mode) => _run(() async {
        final job = (await _api.startMetadataSync(mode: mode)).data!;
        _follow(job);
        unawaited(_history.currentState?.refresh());
      });

  Future<void> _clear(CacheScope scope) async {
    if (scope == CacheScope.ALL) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vider tout le cache ?'),
          content: const Text(
            'Les prochaines recherches et resynchronisations interrogeront à nouveau toutes les sources. '
            'Les livres et leurs couvertures ne changent pas.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Vider')),
          ],
        ),
      );
      if (!(confirmed ?? false)) {
        return;
      }
    }
    await _run(() async {
      final deleted = (await _api.clearIsbnCache(scope: scope)).data!.deleted;
      _info = deleted <= 1 ? '$deleted entrée supprimée du cache.' : '$deleted entrées supprimées du cache.';
      ref.invalidate(metadataAdminProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(metadataAdminProvider);
    ref.listen(metadataAdminProvider, (_, next) {
      final job = next.value?.job;
      if (job != null && _job == null) {
        _follow(job);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: switch (overview) {
        AsyncValue(:final value?) => _content(value),
        AsyncValue(:final error?) => Padding(
            padding: const EdgeInsets.all(16),
            child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(metadataAdminProvider)),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(MetadataAdminResponse overview) {
    final job = _job ?? overview.job;
    final running = job.state == SyncState.RUNNING;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _AdminCard(
              title: 'Métadonnées des livres',
              children: [
                Text(
                  'Les informations des livres viennent de la BnF, d\'Open Library et de Google Books, '
                  'combinées champ par champ.',
                  style: _body,
                ),
                const SizedBox(height: 12),
                Text(
                  '${overview.books} livres, dont ${overview.booksWithIsbn} avec un ISBN.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'Comparer livre par livre',
              children: [
                const Text(
                  'Pour chaque livre, ce que disent la BnF, Open Library et Google Books à côté de ce qui est '
                  'enregistré : reprends une valeur d\'une source, ou interroge à nouveau une source.',
                  style: _body,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/admin/books'),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Ouvrir la comparaison'),
                    style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'Tout resynchroniser',
              children: [
                const Text(
                  'Complète les champs vides et les couvertures manquantes de tous les livres qui ont un ISBN. '
                  'Ce qui est déjà renseigné n\'est jamais remplacé : pour corriger un livre précis, '
                  'utilise la comparaison ou « Resynchroniser » sur sa fiche. « Récupérer seulement » met à jour '
                  'les données des sources sans toucher aux livres, pour les comparer ensuite.',
                  style: _body,
                ),
                const SizedBox(height: 16),
                if (job.state != SyncState.IDLE) ...[_SyncProgress(job: job), const SizedBox(height: 16)],
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy || running || overview.booksWithIsbn == 0 ? null : () => _startSync(SyncMode.FILL),
                      icon: const Icon(Icons.sync),
                      label: Text(running ? 'Resynchronisation en cours…' : 'Lancer la resynchronisation'),
                      style: FilledButton.styleFrom(minimumSize: const Size(44, 48)),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy || running || overview.booksWithIsbn == 0 ? null : () => _startSync(SyncMode.FETCH),
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: const Text('Récupérer seulement'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'Tomes des séries',
              children: [
                SeriesSyncCard(
                  pollInterval: widget.pollInterval,
                  onStarted: () => unawaited(_history.currentState?.refresh()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'Historique des synchronisations',
              children: [SyncHistoryCard(key: _history, pollInterval: widget.pollInterval)],
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'Cache des recherches ISBN',
              children: [
                Text(
                  'Chaque réponse des sources est gardée 180 jours, et un ISBN introuvable 7 jours. '
                  'Le cache contient ${overview.cachedIsbns} ISBN, dont ${overview.cachedNotFound} introuvables.',
                  style: _body,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: _busy || overview.cachedNotFound == 0 ? null : () => _clear(CacheScope.NOT_FOUND),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
                      child: const Text('Oublier les ISBN introuvables'),
                    ),
                    OutlinedButton(
                      onPressed: _busy || overview.cachedIsbns == 0 ? null : () => _clear(CacheScope.ALL),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        minimumSize: const Size(44, 48),
                      ),
                      child: const Text('Vider tout le cache'),
                    ),
                  ],
                ),
              ],
            ),
            if (_info != null) ...[
              const SizedBox(height: 16),
              Semantics(liveRegion: true, child: Text(_info!, style: _body)),
            ],
            if (_error != null) ...[const SizedBox(height: 16), MessageBox.error(_error!)],
          ],
        ),
      ),
    );
  }

  static const _body = TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary);
}

class _SyncProgress extends StatelessWidget {
  const _SyncProgress({required this.job});

  final MetadataSyncJobResponse job;

  @override
  Widget build(BuildContext context) {
    final done = job.state == SyncState.DONE;
    final ratio = job.total == 0 ? 1.0 : job.processed / job.total;
    final counts = [
      '${job.updated} complété${job.updated > 1 ? 's' : ''}',
      '${job.unchanged} inchangé${job.unchanged > 1 ? 's' : ''}',
      if (job.notFound > 0) '${job.notFound} introuvable${job.notFound > 1 ? 's' : ''}',
      if (job.failed > 0) '${job.failed} en échec',
    ].join(' · ');
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            done ? 'Terminé : ${job.processed} livres traités' : '${job.processed} / ${job.total} livres traités',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: AppColors.accent,
              backgroundColor: AppColors.accentLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(counts, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          if (done && job.failed > 0)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Une source ne répondait pas pour certains livres : relance plus tard pour les reprendre.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
