import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../core/theme.dart';

/// A book cover at a 2:3 ratio: the stored image through its signed URL, else a cover drawn from the
/// title on a color picked from it (stable for a given title).
class BookCover extends ConsumerWidget {
  const BookCover({
    super.key,
    required this.title,
    this.authors,
    this.imageUrl,
    this.width,
    this.showText = true,
  });

  final String title;
  final String? authors;

  /// Signed URL relative to the API, as returned in `BookResponse.cover`.
  final String? imageUrl;
  final double? width;

  /// Title and author on the drawn cover; hidden on very small thumbnails.
  final bool showText;

  static Color colorFor(String title) =>
      AppColors.covers[title.codeUnits.fold<int>(0, (sum, c) => sum + c) % AppColors.covers.length];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = BorderRadius.circular((width ?? 120) < 60 ? 4 : 6);
    final drawn = _DrawnCover(title: title, authors: authors, showText: showText);
    final url = imageUrl;
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: radius,
          child: url == null
              ? drawn
              : CachedNetworkImage(
                  imageUrl: ref.watch(appConfigProvider).resolve(url),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => ColoredBox(color: colorFor(title)),
                  errorWidget: (_, _, _) => drawn,
                ),
        ),
      ),
    );
  }
}

class _DrawnCover extends StatelessWidget {
  const _DrawnCover({required this.title, required this.authors, required this.showText});

  final String title;
  final String? authors;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Couverture de $title',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BookCover.colorFor(title),
          border: const Border(left: BorderSide(color: Color(0x2E000000), width: 4)),
        ),
        child: !showText
            ? const SizedBox.expand()
            : Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            height: 1.2,
                            color: Colors.white,
                          ),
                    ),
                    if (authors != null)
                      Text(
                        authors!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Color(0xE6FFFFFF)),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
