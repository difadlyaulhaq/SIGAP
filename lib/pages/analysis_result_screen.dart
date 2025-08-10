// lib/screens/analysis_result_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import 'package:rescuein/theme/theme.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisResultScreen({super.key, required this.imagePath});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String _analysisResult = '';
  String? _errorMessage;
  late final GenerativeModel _model;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAndAnalyze();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndAnalyze() async {
    final apiKey = dotenv.env['gemini_api_key'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _errorMessage = "API Key tidak ditemukan. Periksa file .env Anda.";
        _isLoading = false;
      });
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4, // Lebih konsisten
        topK: 32,
        topP: 1,
        maxOutputTokens: 512, // Batasi output untuk menghemat cost
      ),
    );

    await _analyzeImage();
  }

  // Kompres dan resize gambar untuk menghemat API cost
  Future<Uint8List> _processImage(String imagePath) async {
    final imageFile = File(imagePath);
    final originalBytes = await imageFile.readAsBytes();
    
    // Decode gambar
    img.Image? image = img.decodeImage(originalBytes);
    if (image == null) throw Exception('Gagal memproses gambar');

    // Resize gambar jika terlalu besar (max 800px pada sisi terpanjang)
    if (image.width > 800 || image.height > 800) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? 800 : null,
        height: image.height > image.width ? 800 : null,
      );
    }

    // Kompres gambar (kualitas 85%)
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Proses gambar untuk efisiensi
      final processedImageBytes = await _processImage(widget.imagePath);

      // Prompt yang lebih spesifik dan ringkas
      const prompt = """Analisis gambar untuk P3K:

1. Identifikasi kondisi kulit/luka (jika ada)
2. Jika ada masalah: jelaskan jenis luka dan 3-4 langkah P3K utama
3. Jika tidak ada masalah: konfirmasi kondisi normal
4. Sertakan peringatan medis

Format: gunakan markdown dengan poin-poin singkat.""";

      final imagePart = DataPart('image/jpeg', processedImageBytes);
      final textPart = TextPart(prompt);

      final response = await _model.generateContent([
        Content.multi([textPart, imagePart])
      ]);

      final result = response.text?.trim();
      if (result == null || result.isEmpty) {
        throw Exception('Respons kosong dari AI');
      }

      setState(() {
        _analysisResult = result;
      });

      // Animate hasil
      _slideController.forward();
      
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('quota')) {
      return 'Kuota API habis. Coba lagi nanti.';
    } else if (error.toString().contains('network')) {
      return 'Masalah koneksi. Periksa internet Anda.';
    }
    return 'Gagal menganalisis gambar. Coba lagi.';
  }

  Future<void> _retryAnalysis() async {
    setState(() {
      _slideController.reset();
    });
    await _analyzeImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analisis P3K'),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header dengan gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, primaryColor.withOpacity(0.1)],
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: const Column(
                  children: [
                    Icon(Icons.medical_services, 
                         color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Hasil Analisis Medis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image card dengan shadow
                    Card(
                      elevation: 8,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Image.file(
                          File(widget.imagePath),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status indicator
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isLoading 
                                ? Colors.orange.withOpacity(0.1)
                                : _errorMessage != null
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLoading 
                                    ? Icons.hourglass_empty
                                    : _errorMessage != null
                                        ? Icons.error_outline
                                        : Icons.check_circle_outline,
                                size: 16,
                                color: _isLoading 
                                    ? Colors.orange
                                    : _errorMessage != null
                                        ? Colors.red
                                        : Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLoading 
                                    ? 'Menganalisis...'
                                    : _errorMessage != null
                                        ? 'Error'
                                        : 'Selesai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isLoading 
                                      ? Colors.orange
                                      : _errorMessage != null
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Analysis result
                    if (_isLoading) _buildLoadingWidget(),
                    if (_errorMessage != null) _buildErrorWidget(),
                    if (!_isLoading && _errorMessage == null && _analysisResult.isNotEmpty)
                      _buildResultWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              'Menganalisis gambar...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon tunggu sebentar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, 
                 size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              'Gagal Menganalisis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    return SlideTransition(
      position: _slideAnimation,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology, color: primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Hasil Analisis AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              MarkdownBody(
                data: _analysisResult,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                  h1: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                  h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, 
                         color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hasil ini hanya sebagai panduan awal. Konsultasi dengan tenaga medis untuk kondisi serius.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}