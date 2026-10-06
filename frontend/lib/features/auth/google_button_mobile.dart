import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';

/// "Sign in with Google" button following Google's branding guidelines (white, outlined, the "G" mark),
/// for platforms where the app starts the flow itself (Android).
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: Color(0xFF747775)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(dimension: 20, child: CustomPaint(painter: _GoogleMark())),
          SizedBox(width: 12),
          Text(
            'Se connecter avec Google',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F1F1F)),
          ),
        ],
      ),
    );
  }
}

/// The four-color "G", drawn as arcs and a bar.
class _GoogleMark extends CustomPainter {
  const _GoogleMark();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    Paint paint(int color) => Paint()
      ..color = Color(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const degree = math.pi / 180;
    canvas
      ..drawArc(rect, -40 * degree, -95 * degree, false, paint(0xFFEA4335))
      ..drawArc(rect, -135 * degree, -90 * degree, false, paint(0xFFFBBC05))
      ..drawArc(rect, 135 * degree, -90 * degree, false, paint(0xFF34A853))
      ..drawArc(rect, 45 * degree, -45 * degree, false, paint(0xFF4285F4))
      ..drawRect(
        Rect.fromLTWH(size.width / 2, size.height / 2 - stroke / 2, size.width / 2, stroke),
        Paint()..color = const Color(0xFF4285F4),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
