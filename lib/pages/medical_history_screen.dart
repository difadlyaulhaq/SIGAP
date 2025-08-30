import 'package:flutter/material.dart';
import 'package:rescuein/models/medical_history_model.dart';
import 'package:rescuein/theme/theme.dart';

class MedicalHistoryScreen extends StatelessWidget {
  final MedicalHistoryModel medicalHistory;

  const MedicalHistoryScreen({super.key, required this.medicalHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildAppBar(context),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Riwayat Medis',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: primaryGradient,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required List<String> items,
      required String noneMessage}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: smallRadius,
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: headingSmallTextStyle),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(
              height: 1,
              color: borderColor,
            ),
            const SizedBox(height: AppSpacing.md),
            if (items.isEmpty || (items.length == 1 && items.first.contains('Tidak ada')))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  noneMessage,
                  style: bodyMediumTextStyle.copyWith(
                    color: textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: bodyMediumTextStyle,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: smallRadius,
                  ),
                  child: Icon(Icons.note_alt_outlined, color: primaryColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Catatan Tambahan', style: headingSmallTextStyle),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(
              height: 1,
              color: borderColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: smallRadius,
                border: Border.all(color: borderColor),
              ),
              child: Text(
                medicalHistory.catatanTambahan.isEmpty
                    ? 'Tidak ada catatan tambahan.'
                    : medicalHistory.catatanTambahan,
                style: bodyMediumTextStyle.copyWith(
                  color: medicalHistory.catatanTambahan.isEmpty 
                      ? textSecondaryColor 
                      : textPrimaryColor,
                  height: 1.5,
                  fontStyle: medicalHistory.catatanTambahan.isEmpty 
                      ? FontStyle.italic 
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}