import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Three books on a shelf, on the accent color (or translucent white on an accent background).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size, this.onAccent = false});

  final double size;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onAccent ? const Color(0x24FFFFFF) : AppColors.accent,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.auto_stories_outlined, color: Colors.white, size: size * 0.55),
    );
  }
}
