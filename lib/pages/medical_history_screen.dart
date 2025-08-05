import 'package:flutter/material.dart';
import 'package:rescuein/models/medical_history_model.dart';
import 'package:rescuein/theme/theme.dart';

class MedicalHistoryScreen extends StatelessWidget {
  final MedicalHistoryModel medicalHistory;

  const MedicalHistoryScreen({super.key, required this.medicalHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Medis'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              context,
              icon: Icons.warning_amber_outlined,
              title: 'Alergi',
              items: medicalHistory.alergi,
              noneMessage: 'Tidak ada data alergi.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionCard(
              context,
              icon: Icons.medical_information_outlined,
              title: 'Riwayat Penyakit',
              items: medicalHistory.riwayatPenyakit,
              noneMessage: 'Tidak ada data riwayat penyakit.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionCard(
              context,
              icon: Icons.medication_outlined,
              title: 'Obat Rutin',
              items: medicalHistory.obatRutin,
              noneMessage: 'Tidak ada data konsumsi obat rutin.',
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildNotesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required List<String> items,
      required String noneMessage}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 28),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: headingSmallTextStyle),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            if (items.isEmpty || (items.length == 1 && items.first.contains('Tidak ada')))
              Text(noneMessage, style: bodyMediumTextStyle.copyWith(color: textSecondaryColor))
            else
              ...items.map((item) => ListTile(
                    leading: Icon(Icons.check_circle_outline, color: successColor),
                    title: Text(item, style: bodyMediumTextStyle),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt_outlined, color: primaryColor, size: 28),
                const SizedBox(width: AppSpacing.md),
                Text('Catatan Tambahan', style: headingSmallTextStyle),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Text(
              medicalHistory.catatanTambahan.isEmpty
                  ? 'Tidak ada catatan tambahan.'
                  : medicalHistory.catatanTambahan,
              style: bodyMediumTextStyle.copyWith(color: textSecondaryColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}