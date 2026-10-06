import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Mock-up 3 · Scan ISBN: the camera (webcam on the web) reads the EAN-13 barcode on the back of a book.
/// Pops with the ISBN, with '' to type it instead, or with null when closed.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  /// ISBN barcodes are EAN-13 starting with 978 or 979 ("Bookland").
  static bool isIsbn(String? code) => code != null && RegExp(r'^97[89]\d{10}$').hasMatch(code);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.ean13]);
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) {
      return;
    }
    for (final barcode in capture.barcodes) {
      if (ScanScreen.isIsbn(barcode.rawValue)) {
        _done = true;
        context.pop(barcode.rawValue);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15181B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Caméra indisponible. Autorise l\'accès à la caméra ou saisis l\'ISBN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          const _Viewfinder(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Fermer',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, state, _) => state.torchState == TorchState.unavailable
                            ? const SizedBox.shrink()
                            : IconButton.filledTonal(
                                tooltip: 'Lampe',
                                isSelected: state.torchState == TorchState.on,
                                onPressed: _controller.toggleTorch,
                                icon: const Icon(Icons.flashlight_on_outlined),
                              ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () => context.pop(''),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: const Text('Pas de code-barres ? Saisir l\'ISBN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Vise le code-barres au dos du livre', style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
