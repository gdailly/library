import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import 'sync_labels.dart';

/// Administration · one synchronisation, item by item (most recent first), followed live while it runs.
class SyncRunScreen extends ConsumerStatefulWidget {
  const SyncRunScreen({super.key, required this.runId, this.pollInterval = const Duration(seconds: 2)});

  final int runId;
  final Duration pollInterval;

  @override
  ConsumerState<SyncRunScreen> createState() => _SyncRunScreenState();
}

class _SyncRunScreenState extends ConsumerState<SyncRunScreen> {
  Timer? _timer;
  SyncRunResponse? _run;
  List<SyncRunItemResponse> _items = const [];
  int _totalItems = 0;
  int _pages = 1;
  int _totalPages = 1;
  bool _problemsOnly = false;
  Object? _error;

  AdminApi get _api => ref.read(libraryApiProvider).getAdminApi();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    _timer?.cancel();
    try {
      final run = (await _api.getSyncRun(id: widget.runId)).data!;
      final items = <SyncRunItemResponse>[];
      var total = 0;
      var totalPages = 1;
      for (var page = 0; page < _pages; page++) {
        final response = (await _api.listSyncRunItems(id: widget.runId, problemsOnly: _problemsOnly, page: page)).data!;
        items.addAll(response.items);
        total = response.totalItems;
        totalPages = response.totalPages;
        if (page + 1 >= response.totalPages) {
          break;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _run = run;
        _items = items;
        _totalItems = total;
        _totalPages = totalPages;
        _error = null;
      });
      if (run.state == SyncRunState.RUNNING) {
        _timer = Timer(widget.pollInterval, _refresh);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e);
      if (_run?.state == SyncRunState.RUNNING) {
        _timer = Timer(widget.pollInterval, _refresh);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    return Scaffold(
      appBar: AppBar(title: Text(run == null ? 'Synchronisation' : syncKindLabel(run.kind))),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: run == null
              ? (_error != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: MessageBox.error(errorMessage(_error!), onRetry: _refresh),
                    )
                  : const Center(child: CircularProgressIndicator()))
              : _content(run),
        ),
      ),
    );
  }

  Widget _content(SyncRunResponse run) {
    final running = run.state == SyncRunState.RUNNING;
    final noun = syncOnSeries(run.kind) ? 'séries' : 'livres';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    running ? '${run.processed} / ${run.total} $noun traités' : '${run.processed} $noun traités',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  SyncTag.state(run.state),
                ],
              ),
              const SizedBox(height: 6),
              Text(syncWhen(run), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              SyncProgressBar(run: run),
              const SizedBox(height: 8),
              Text(syncCounts(run), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              if (run.state == SyncRunState.INTERRUPTED)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Le serveur a redémarré pendant la synchronisation : relance-la pour traiter le reste.',
                    style: TextStyle(fontSize: 13, color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Seulement les introuvables et les échecs'),
          value: _problemsOnly,
          onChanged: (value) {
            setState(() {
              _problemsOnly = value;
              _pages = 1;
            });
            _refresh();
          },
        ),
        if (_error != null) ...[MessageBox.error(errorMessage(_error!), onRetry: _refresh), const SizedBox(height: 8)],
        Text(
          '$_totalItems élément${_totalItems > 1 ? 's' : ''}${running ? ', les plus récents en haut' : ''}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              running ? 'En attente du premier élément…' : 'Aucun élément.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        for (final item in _items) _ItemLine(item: item),
        if (_pages < _totalPages)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _pages++);
                  _refresh();
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(44, 48)),
                child: const Text('Voir plus'),
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine({required this.item});

  final SyncRunItemResponse item;

  @override
  Widget build(BuildContext context) {
    final local = item.createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (item.detail != null) ...[
                  const SizedBox(height: 2),
                  Text(item.detail!, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SyncTag.outcome(item.outcome),
              const SizedBox(height: 4),
              Text(
                '${two(local.hour)}:${two(local.minute)}:${two(local.second)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
