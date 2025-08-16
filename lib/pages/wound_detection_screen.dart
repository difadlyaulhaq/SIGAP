import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rescuein/pages/analysis_result_screen.dart';

/// Manages the UI state of the screen for clarity.
enum ScreenState { loading, ready, permissionDenied, error }

class WoundDetectionScreen extends StatefulWidget {
  const WoundDetectionScreen({super.key});

  @override
  State<WoundDetectionScreen> createState() => _WoundDetectionScreenState();
}

class _WoundDetectionScreenState extends State<WoundDetectionScreen> with WidgetsBindingObserver {
  // State Management
  ScreenState _screenState = ScreenState.loading;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;

  /// Guard to prevent image picker/camera from being activated multiple times.
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Handles app lifecycle changes to re-initialize the camera if needed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // --- Core Logic ---

  /// Main initialization function.
  Future<void> _initialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      if(mounted) setState(() => _screenState = ScreenState.permissionDenied);
    }
  }

  /// Sets up the camera controller.
  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
        if (_cameras.isEmpty) {
          if(mounted) setState(() => _screenState = ScreenState.error);
          return;
        }
      } catch (e) {
        if(mounted) setState(() => _screenState = ScreenState.error);
        return;
      }
    }

    // Dispose the old controller before creating a new one
    await _controller?.dispose();
    final cameraDescription = _cameras[_selectedCameraIndex];
    
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      if(mounted) setState(() => _screenState = ScreenState.ready);
    } catch (e) {
      if(mounted) setState(() => _screenState = ScreenState.error);
    }
  }

  // --- Camera & Gallery Actions ---

  /// Toggles the camera flash between on and off.
  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isFlashOn = !_isFlashOn);
    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
  }

  /// Switches between the front and back cameras.
  Future<void> _toggleCamera() async {
    if (_cameras.length > 1) {
      setState(() {
        _screenState = ScreenState.loading;
        _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      });
      await _initializeCamera();
    }
  }

  /// Captures a picture and navigates to the result screen.
  Future<void> _takePicture() async {
    if (_isActionInProgress || _controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isActionInProgress = true);
    
    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      // Optional: Show an error message to the user
    } finally {
      if(mounted) setState(() => _isActionInProgress = false);
    }
  }

  /// Picks an image from the gallery and navigates to the result screen.
  Future<void> _pickImageFromGallery() async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      // Optional: Show an error message to the user
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }
  
  // --- UI Builder ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Deteksi Luka'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_screenState == ScreenState.ready) ...[
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: _toggleFlash,
              tooltip: 'Flash',
            ),
            if (_cameras.length > 1)
              IconButton(
                icon: const Icon(Icons.flip_camera_ios_outlined),
                onPressed: _toggleCamera,
                tooltip: 'Ganti Kamera',
              ),
          ]
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
    );
  }

  /// Builds the main body of the screen based on the current state.
  Widget _buildBody() {
    switch (_screenState) {
      case ScreenState.ready:
        return _buildCameraPreview();
      case ScreenState.permissionDenied:
        return _buildPermissionDeniedUI();
      case ScreenState.error:
        return _buildInfoUI(
          key: const ValueKey('error'),
          icon: Icons.error_outline,
          message: "Kamera tidak dapat diakses.\nCoba mulai ulang aplikasi.",
        );
      case ScreenState.loading:
      return _buildLoadingUI();
    }
  }

  /// The main UI when the camera is ready.
  Widget _buildCameraPreview() {
    return Stack(
      key: const ValueKey('ready'),
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildControlUI(),
        ),
      ],
    );
  }

  /// The control bar with gallery, shutter, and flip camera buttons.
  Widget _buildControlUI() {
    final Color disabledColor = Colors.white.withOpacity(0.5);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _isActionInProgress ? null : _pickImageFromGallery,
            icon: Icon(Icons.photo_library_outlined, color: _isActionInProgress ? disabledColor : Colors.white),
            iconSize: 32,
            tooltip: 'Upload dari Galeri',
          ),
          _buildCaptureButton(),
          SizedBox(width: 48, height: 48), // Spacer for balance
        ],
      ),
    );
  }

  /// The main shutter button.
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isActionInProgress ? null : _takePicture,
      child: Opacity(
        opacity: _isActionInProgress ? 0.6 : 1.0,
        child: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// UI for when camera permission is denied by the user.
  Widget _buildPermissionDeniedUI() {
    return _buildInfoUI(
      key: const ValueKey('permission_denied'),
      icon: Icons.camera_alt_outlined,
      message: "Izin kamera dibutuhkan untuk fitur ini.",
      action: ElevatedButton.icon(
        icon: const Icon(Icons.settings),
        label: const Text('Buka Pengaturan'),
        onPressed: openAppSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  /// A generic UI for displaying information (like errors or permissions).
  Widget _buildInfoUI({required String message, required IconData icon, Key? key, Widget? action}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 80),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ]
        ],
      ),
    );
  }

  /// A simple loading indicator.
  Widget _buildLoadingUI() {
    return Center(
      key: const ValueKey('loading'),
      child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
    );
     }
}