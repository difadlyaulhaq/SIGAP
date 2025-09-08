// lib/pages/emergency_qr_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rescuein/theme/theme.dart';

class EmergencyQrScreen extends StatelessWidget {
  final String emergencyUrl;

  const EmergencyQrScreen({super.key, required this.emergencyUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text('Kode QR Darurat', style: headingSmallTextStyle),
        backgroundColor: cardColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: largeRadius,
                  boxShadow: [cardShadow],
                ),
                child: QrImageView(
                  data: emergencyUrl, // URL unik Anda
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: false,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Tunjukkan Kode QR Ini Saat Darurat',
                style: headingSmallTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Petugas medis dapat memindai kode ini untuk melihat riwayat medis penting Anda tanpa perlu masuk ke aplikasi.',
                style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                 padding: const EdgeInsets.all(AppSpacing.lg),
                 decoration: BoxDecoration(
                   color: warningColor.withOpacity(0.1),
                   borderRadius: mediumRadius,
                   border: Border.all(color: warningColor.withOpacity(0.3))
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.shield_outlined, color: warningColor, size: 32),
                     const SizedBox(width: AppSpacing.md),
                     Expanded(
                       child: Text(
                         'Saran: Ambil screenshot halaman ini dan jadikan wallpaper layar kunci Anda.',
                         style: bodyMediumTextStyle.copyWith(color: warningColor.withOpacity(0.9)),
                       ),
                     ),
                   ],
                 ),
              )
            ],
          ),
        ),
      ),
    );
  }
}