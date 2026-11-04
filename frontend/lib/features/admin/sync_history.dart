import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import 'sync_labels.dart';

/// One synchronisation of the history: what it did, when, and its progress while it runs.
class SyncRunTile extends StatelessWidget {
  const SyncRunTile({super.key, required this.run});

  final SyncRunResponse run;

  @override
  Widget build(BuildContext context) {
    final running = run.state == SyncRunState.RUNNING;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/admin/syncs/${run.id}'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: Icon(syncKindIcon(run.kind), size: 20, color: AppColors.textSecondary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(syncKindLabel(run.kind), style: const TextStyle(fontWeight: FontWeight.w600)),
                        SyncTag.state(run.state),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(syncWhen(run), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (running) ...[
                      const SizedBox(height: 8),
                      SyncProgressBar(run: run),
                      const SizedBox(height: 6),
                      Text('${run.processed} / ${run.total}', style: const TextStyle(fontSize: 13)),
                    ],
                    const SizedBox(height: 4),
                    Text(syncCounts(run), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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

/// Reads a page of the history again and again: often while a synchronisation runs, now and then otherwise, so that
/// one started meanwhile (by a button of the page or by the hourly task) shows up.
mixin _SyncRunsPolling<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Timer? _timer;
  List<SyncRunResponse>? runs;
  int totalPages = 1;
  Object? error;

  Duration get pollInterval;
  int get pages => 1;

  AdminApi get api => ref.read(libraryApiProvider).getAdminApi();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    _timer?.cancel();
    try {
      final loaded = <SyncRunResponse>[];
      var total = 1;
      for (var page = 0; page < pages; page++) {
        final response = (await api.listSyncRuns(page: page)).data!;
        loaded.addAll(response.items);
        total = response.totalPages;
        if (page + 1 >= response.totalPages) {
          break;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        runs = loaded;
        totalPages = total;
        error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => error = e);
    }
    final running = runs?.any((run) => run.state == SyncRunState.RUNNING) ?? false;
    _timer = Timer(running ? pollInterval : pollInterval * 5, refresh);
  }
}

/// Administration card: the last synchronisations, followed live.
class SyncHistoryCard extends ConsumerStatefulWidget {
  const SyncHistoryCard({super.key, required this.pollInterval});

  final Duration pollInterval;

  @override
  ConsumerState<SyncHistoryCard> createState() => SyncHistoryCardState();
}

class SyncHistoryCardState extends ConsumerState<SyncHistoryCard> with _SyncRunsPolling {
  static const shown = 5;

  @override
  Duration get pollInterval => widget.pollInterval;

  @override
  Widget build(BuildContext context) {
    final runs = this.runs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Les resynchronisations des livres et des séries des 30 derniers jours, y compris la récupération '
          'automatique des tomes. Ouvre-en une pour voir ce qu\'elle a fait livre par livre ou série par série.',
          style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (runs == null && error != null)
          MessageBox.error(errorMessage(error!), onRetry: refresh)
        else if (runs == null)
          const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
        else if (runs.isEmpty)
          const Text('Aucune synchronisation pour le moment.', style: TextStyle(color: AppColors.textSecondary))
        else ...[
          for (final run in runs.take(shown)) SyncRunTile(run: run),
          if (runs.length > shown || totalPages > 1) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/admin/syncs'),
              icon: const Icon(Icons.history),
              label: const Text('Tout l\'historique'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
            ),
          ],
        ],
      ],
    );
  }
}

/// Administration · every synchronisation of the last 30 days.
class SyncRunsScreen extends ConsumerStatefulWidget {
  const SyncRunsScreen({super.key, this.pollInterval = const Duration(seconds: 2)});

  final Duration pollInterval;

  @override
  ConsumerState<SyncRunsScreen> createState() => _SyncRunsScreenState();
}

class _SyncRunsScreenState extends ConsumerState<SyncRunsScreen> with _SyncRunsPolling {
  int _pages = 1;

  @override
  Duration get pollInterval => widget.pollInterval;

  @override
  int get pages => _pages;

  @override
  Widget build(BuildContext context) {
    final runs = this.runs;
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des synchronisations')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: switch ((runs, error)) {
            (null, final Object error) => Padding(
                padding: const EdgeInsets.all(16),
                child: MessageBox.error(errorMessage(error), onRetry: refresh),
              ),
            (null, _) => const Center(child: CircularProgressIndicator()),
            (final List<SyncRunResponse> runs, _) when runs.isEmpty => const Center(
                child: Text('Aucune synchronisation ces 30 derniers jours.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            (final List<SyncRunResponse> runs, _) => ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                children: [
                  for (final run in runs) SyncRunTile(run: run),
                  if (_pages < totalPages)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Center(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _pages++);
                            refresh();
                          },
                          style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
                          child: const Text('Voir plus'),
                        ),
                      ),
                    ),
                ],
              ),
          },
        ),
      ),
    );
  }
}
