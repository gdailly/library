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
        for (final item in _items) _ItemLine(key: ValueKey(item.id), runId: widget.runId, item: item),
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

class _ItemLine extends ConsumerStatefulWidget {
  const _ItemLine({super.key, required this.runId, required this.item});

  final int runId;
  final SyncRunItemResponse item;

  @override
  ConsumerState<_ItemLine> createState() => _ItemLineState();
}

/// A book or a series; a series opens on its volumes, read when first opened.
class _ItemLineState extends ConsumerState<_ItemLine> {
  bool _open = false;
  List<SyncRunItemResponse>? _children;
  Object? _error;

  Future<void> _toggle() async {
    setState(() => _open = !_open);
    if (!_open || _children != null) {
      return;
    }
    try {
      final children = (await ref
              .read(libraryApiProvider)
              .getAdminApi()
              .listSyncRunItemChildren(id: widget.runId, itemId: widget.item.id))
          .data!;
      if (mounted) {
        setState(() {
          _children = children;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final expandable = item.childCount > 0;
    final line = _Line(
      item: item,
      leading: expandable
          ? Icon(_open ? Icons.expand_less : Icons.expand_more, size: 20, color: AppColors.textSecondary)
          : null,
      showTime: true,
    );
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (expandable)
            Semantics(
              button: true,
              expanded: _open,
              hint: '${item.childCount} tome${item.childCount > 1 ? 's' : ''}',
              child: InkWell(onTap: _toggle, child: line),
            )
          else
            line,
          if (_open)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 8),
              child: switch ((_children, _error)) {
                (final List<SyncRunItemResponse> children, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (final child in children) _Line(item: child, dense: true)],
                  ),
                (_, final Object error) => MessageBox.error(errorMessage(error), onRetry: () {
                    setState(() => _open = false);
                    _toggle();
                  }),
                _ => const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
              },
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.item, this.leading, this.showTime = false, this.dense = false});

  final SyncRunItemResponse item;
  final Widget? leading;
  final bool showTime;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final local = item.createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 36 : 48),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 6 : 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) Padding(padding: const EdgeInsets.only(right: 8), child: leading),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: TextStyle(fontWeight: dense ? FontWeight.w500 : FontWeight.w600)),
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
                if (showTime) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${two(local.hour)}:${two(local.minute)}:${two(local.second)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
