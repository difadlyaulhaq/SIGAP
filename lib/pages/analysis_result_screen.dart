// lib/screens/analysis_result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:rescuein/theme/theme.dart'; // Sesuaikan dengan path tema Anda

class AnalysisResultScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisResultScreen({super.key, required this.imagePath});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isLoading = true;
  String _analysisResult = '';
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeAndAnalyze();
  }

  Future<void> _initializeAndAnalyze() async {
    final apiKey = dotenv.env['gemini_api_key'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _analysisResult = "Error: gemini_api_key tidak ditemukan. Harap periksa file .env Anda.";
        _isLoading = false;
      });
      return;
    }

    // Gunakan model yang mendukung input gambar (vision)
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest', // Model ini sudah multimodal
      apiKey: apiKey,
    );

    await _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imageBytes = await File(widget.imagePath).readAsBytes();

      // Ini adalah bagian terpenting: prompt yang menginstruksikan AI
      final prompt = TextPart(
        "Anda adalah asisten P3K virtual. Analisislah gambar ini dengan saksama. "
        "1. Identifikasi apakah ada luka, lecet, memar, atau masalah kulit lainnya. "
        "2. Jika ada, jelaskan kemungkinan jenis masalahnya (contoh: luka gores, luka bakar ringan, dll.) dan berikan langkah-langkah pertolongan pertama yang jelas dan ringkas. "
        "3. Jika gambar tidak menunjukkan adanya luka atau masalah yang jelas, berikan respons yang menenangkan seperti 'Dari gambar yang terlihat, kulit Anda tampak baik-baik saja. Tidak ada luka atau memar yang jelas terlihat.' "
        "4. Selalu sertakan disclaimer di akhir jawaban: 'Penting: Analisis ini hanya berdasarkan gambar dan bukan pengganti diagnosis medis profesional. Untuk kondisi yang serius atau jika Anda ragu, segera konsultasikan dengan dokter.' "
        "Berikan jawaban dalam format Markdown."
      );

      final imagePart = DataPart('image/jpeg', imageBytes);

      // Mengirim konten multimodal (teks + gambar)
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      setState(() {
        _analysisResult = response.text ?? "Tidak dapat menerima respons dari AI.";
      });
    } catch (e) {
      setState(() {
        _analysisResult = "Terjadi kesalahan saat menganalisis gambar: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis Luka'),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar yang dianalisis
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(widget.imagePath)),
            ),
            const SizedBox(height: 24),
            Text("Analisis AI:", style: headingSmallTextStyle),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor)
                    ),
                    // Gunakan Markdown untuk menampilkan hasil dengan format yang baik
                    child: MarkdownBody(
                      data: _analysisResult,
                      selectable: true,
                       styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                         p: bodyMediumTextStyle,
                       ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}