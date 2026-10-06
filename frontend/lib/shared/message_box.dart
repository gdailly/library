import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Inline message of the mock-ups: dark red on light red for errors.
class MessageBox extends StatelessWidget {
  const MessageBox.error(this.message, {super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 14, height: 1.45)),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(foregroundColor: AppColors.error, minimumSize: const Size(44, 44)),
                child: const Text('Réessayer'),
              ),
          ],
        ),
      ),
    );
  }
}
