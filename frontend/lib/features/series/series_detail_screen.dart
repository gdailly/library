import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/api.dart';
import '../../core/theme.dart';
import '../../shared/message_box.dart';
import '../auth/auth_controller.dart';
import '../books/book_cover.dart';
import 'series_labels.dart';
import 'series_providers.dart';

/// What the library has of a volume.
enum VolumeState { owned, wished, missing }

VolumeState stateOf(SeriesVolumeResponse volume) {
  if (volume.books.any((book) => book.owned)) {
    return VolumeState.owned;
  }
  return volume.books.isEmpty ? VolumeState.missing : VolumeState.wished;
}

/// One series volume by volume: the albums of the library in colour, the others greyed with what the BnF lists.
class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(seriesVolumesProvider(name));
    final auth = ref.watch(authControllerProvider);
    final isAdmin = auth is AuthSignedIn && auth.me.admin;
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.name ?? name),
        actions: [if (isAdmin && detail.hasValue) SyncSeriesButton(name: name)],
      ),
      body: switch (detail) {
        AsyncValue(:final value?) => _content(context, value),
        AsyncValue(:final error?) => Padding(
            padding: const EdgeInsets.all(16),
            child: MessageBox.error(errorMessage(error), onRetry: () => ref.invalidate(seriesVolumesProvider(name))),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, SeriesDetailResponse detail) {
    final owned = detail.volumes.where((v) => stateOf(v) == VolumeState.owned).length;
    final missing = detail.volumes.where((v) => stateOf(v) != VolumeState.owned).map((v) => v.number).toList();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (detail.volumes.isNotEmpty)
              Text(
                [
                  '$owned tome${owned > 1 ? 's' : ''} sur ${detail.volumes.length} dans la bibliothèque',
                  if (missing.isNotEmpty) 'manque ${volumeRanges(missing)}',
                ].join(' · '),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                detail.catalogFetchedAt == null
                    ? 'La liste complète des tomes est en cours de récupération auprès de la BnF.'
                    : 'Liste des tomes d\'après la BnF.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [for (final volume in detail.volumes) VolumeTile(volume: volume)],
            ),
            if (detail.unnumbered.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Sans numéro de tome', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  for (final book in detail.unnumbered)
                    VolumeTile(
                      volume: SeriesVolumeResponse(number: 0, title: book.title, books: [book]),
                      showNumber: false,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A volume's cover with a tag: in colour when owned, greyed otherwise.
/// Lists the volumes of the series again from the BnF now (the administrator only).
class SyncSeriesButton extends ConsumerStatefulWidget {
  const SyncSeriesButton({super.key, required this.name});

  final String name;

  @override
  ConsumerState<SyncSeriesButton> createState() => _SyncSeriesButtonState();
}

class _SyncSeriesButtonState extends ConsumerState<SyncSeriesButton> {
  bool _busy = false;

  Future<void> _sync() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final detail = (await ref.read(libraryApiProvider).getAdminApi().syncOneSeries(name: widget.name)).data!;
      ref
        ..invalidate(seriesVolumesProvider(widget.name))
        ..invalidate(seriesListProvider);
      messenger.showSnackBar(SnackBar(
        content: Text('Série resynchronisée : ${detail.volumes.length} tome${detail.volumes.length > 1 ? 's' : ''} connu${detail.volumes.length > 1 ? 's' : ''}.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(e))));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Resynchroniser la série',
      onPressed: _busy ? null : _sync,
      icon: _busy
          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.sync),
    );
  }
}

class VolumeTile extends StatelessWidget {
  const VolumeTile({super.key, required this.volume, this.showNumber = true});

  final SeriesVolumeResponse volume;
  final bool showNumber;

  static const width = 112.0;

  @override
  Widget build(BuildContext context) {
    final state = stateOf(volume);
    final book = volume.books.where((b) => b.owned).firstOrNull ?? volume.books.firstOrNull;
    final title = volume.title ?? book?.title ?? 'Tome ${volume.number}';
    final cover = BookCover(
      title: title,
      authors: book?.authors,
      imageUrl: book?.cover?.thumbUrl ?? volume.coverUrl,
      width: width,
    );
    final tile = SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              state == VolumeState.owned
                  ? cover
                  : Opacity(opacity: 0.55, child: ColorFiltered(colorFilter: _greyscale, child: cover)),
              Positioned(left: 6, top: 6, child: _Tag(state: state)),
            ],
          ),
          const SizedBox(height: 6),
          if (showNumber)
            Text('Tome ${volume.number}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: state == VolumeState.owned ? AppColors.text : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
    if (book == null) {
      return Semantics(label: '$title, ${_Tag.label(state)}', child: tile);
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => context.push('/books/${book.id}'),
      child: tile,
    );
  }

  static const _greyscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

class _Tag extends StatelessWidget {
  const _Tag({required this.state});

  final VolumeState state;

  static String label(VolumeState state) => switch (state) {
        VolumeState.owned => 'Possédé',
        VolumeState.wished => 'Envie',
        VolumeState.missing => 'Manquant',
      };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (state) {
      VolumeState.owned => (AppColors.accent, Colors.white),
      VolumeState.wished => (AppColors.text, Colors.white),
      VolumeState.missing => (AppColors.errorBackground, AppColors.error),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(label(state),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground)),
      ),
    );
  }
}
