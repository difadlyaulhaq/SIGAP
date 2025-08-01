import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/theme.dart'; // Sesuaikan path impor tema Anda

// Enum untuk mengelola state UI dengan lebih bersih
enum ScreenState { loading, ready, permissionDenied, error }

class WoundDetectionScreen extends StatefulWidget {
  const WoundDetectionScreen({super.key});

  @override
  State<WoundDetectionScreen> createState() => _WoundDetectionScreenState();
}

class _WoundDetectionScreenState extends State<WoundDetectionScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // State Management
  ScreenState _screenState = ScreenState.loading;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAndInitializeCamera();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // --- LOGIKA INTI ---

  Future<void> _requestAndInitializeCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      await _initializeCamera();
    } else {
      setState(() => _screenState = ScreenState.permissionDenied);
    }
  }

  Future<void> _initializeCamera() async {
    // Pastikan _cameras sudah terisi
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _screenState = ScreenState.error);
        return;
      }
    }

    // Buang controller lama jika ada
    await _controller?.dispose();

    final cameraDescription = _cameras[_selectedCameraIndex];
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      // Set flash mode ke state saat ini
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() => _screenState = ScreenState.ready);
    } catch (e) {
      setState(() => _screenState = ScreenState.error);
    }
  }
  
  // --- KONTROL KAMERA ---

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length > 1) {
      setState(() {
        _screenState = ScreenState.loading; // Tampilkan loading saat ganti kamera
        _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      });
      await _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;
      // TODO: Proses gambar (image.path) di halaman selanjutnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar berhasil diambil: ${image.path}')),
      );
    } catch (e) {
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      // TODO: Proses gambar (image.path) di halaman selanjutnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gambar dipilih: ${image.path}')),
      );
    }
  }
  
  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Deteksi Luka'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Hanya tampilkan tombol jika kamera siap
          if (_screenState == ScreenState.ready) ...[
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleFlash,
              tooltip: 'Flash',
            ),
            if (_cameras.length > 1) // Hanya tampilkan jika ada > 1 kamera
              IconButton(
                icon: const Icon(Icons.flip_camera_ios_outlined),
                onPressed: _toggleCamera,
                tooltip: 'Ganti Kamera',
              ),
          ]
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_screenState) {
      case ScreenState.ready:
        return _buildReadyUI();
      case ScreenState.permissionDenied:
        return _buildPermissionDeniedUI();
      case ScreenState.error:
        return _buildErrorUI("Gagal memuat kamera.");
      case ScreenState.loading:
      return _buildLoadingUI();
    }
  }

  Widget _buildReadyUI() {
    return Stack(
      key: const ValueKey('ready'),
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildControlUI()),
      ],
    );
  }

  Widget _buildControlUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _pickImageFromGallery,
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 32),
            tooltip: 'Upload dari Galeri',
          ),
          _buildCaptureButton(),
          // Spacer untuk menyeimbangkan, atau tombol lain
          SizedBox(width: 48, height: 48), 
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: primaryColor.withOpacity(0.5), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ]
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPermissionDeniedUI() {
    return _buildErrorUI(
      key: const ValueKey('permission_denied'),
      "Fitur ini memerlukan izin kamera untuk berfungsi.",
      action: ElevatedButton.icon(
        icon: const Icon(Icons.settings),
        label: const Text('Buka Pengaturan'),
        onPressed: openAppSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
        ),
      ),
    );
  }

  Widget _buildErrorUI(String message, {Key? key, Widget? action}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: errorColor, size: 80),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: headingSmallTextStyle.copyWith(color: whiteColor),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action,
          ]
        ],
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      key: const ValueKey('loading'),
      child: CircularProgressIndicator(color: primaryColor),
    );
  }
}