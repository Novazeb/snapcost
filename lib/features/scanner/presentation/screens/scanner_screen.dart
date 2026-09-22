import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../../services/ocr_service.dart';
import '../../../expenses/presentation/screens/expense_form_screen.dart';
import '../widgets/viewfinder_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    AppHaptic.mediumImpact();

    try {
      String imagePath = '';
      if (_isCameraInitialized && _cameraController != null) {
        final xFile = await _cameraController!.takePicture();
        imagePath = xFile.path;
      }

      final parsedData = await OCRService.processImage(imagePath);
      AppHaptic.successNotification();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(scannedData: parsedData),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing scan: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _isProcessing = true;
      });

      final parsedData = await OCRService.processImage(image.path);
      AppHaptic.successNotification();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseFormScreen(scannedData: parsedData),
          ),
        );
      }
    }
  }

  Future<void> _triggerDemoScan(String merchant, double amount, String category) async {
    setState(() {
      _isProcessing = true;
    });

    AppHaptic.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 600));

    final parsedData = await OCRService.processMockSample(
      merchant: merchant,
      totalAmount: amount,
      category: category,
    );

    AppHaptic.successNotification();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseFormScreen(scannedData: parsedData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview or Fallback Background
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.document_scanner_rounded,
                      size: 64,
                      color: AppColors.darkAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mode Simulasi ML Kit AI OCR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Kamera tidak aktif di environment ini. Gunakan galeri atau pilih sampel resi berikut:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Demo Preset Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.shopping_cart, size: 16, color: Colors.white),
                          label: const Text('Resi Alfamart (Rp 75.500)'),
                          backgroundColor: Colors.white12,
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          onPressed: () => _triggerDemoScan('Alfamart Meruya', 75500, 'groceries'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.local_cafe, size: 16, color: Colors.white),
                          label: const Text('Resi Starbucks (Rp 68.000)'),
                          backgroundColor: Colors.white12,
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          onPressed: () => _triggerDemoScan('Starbucks Coffee', 68000, 'food'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.local_gas_station, size: 16, color: Colors.white),
                          label: const Text('Resi Pertamina (Rp 250.000)'),
                          backgroundColor: Colors.white12,
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          onPressed: () => _triggerDemoScan('Pertamina SPBU', 250000, 'transport'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Guided Viewfinder Overlay
          const ViewfinderOverlay(),

          // Top Header Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const Text(
                    'Pindai Resi AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _pickGalleryImage,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Shutter Button Area
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _isProcessing
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.darkAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _captureAndProcess,
                      child: Container(
                        height: 76,
                        width: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: AppColors.darkAccent,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
