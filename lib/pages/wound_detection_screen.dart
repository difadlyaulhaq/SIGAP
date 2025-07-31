import 'package:flutter/material.dart';

class WoundDetectionScreen extends StatelessWidget {
  const WoundDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Luka'),
      ),
      body: const Center(
        child: Text(
          'Halaman untuk fitur deteksi luka akan muncul di sini.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}