import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'ar_overlay.dart';

class ArScannerScreen extends StatefulWidget {
  const ArScannerScreen({super.key});

  @override
  State<ArScannerScreen> createState() => _ArScannerScreenState();
}

class _ArScannerScreenState extends State<ArScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? _detectedCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value != null && value != _detectedCode) {
      setState(() => _detectedCode = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: live camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Layer 2: AR overlay when marker detected
          if (_detectedCode != null)
            ArOverlay(markerCode: _detectedCode!),
          // Layer 3: close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => setState(() => _detectedCode = null),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}