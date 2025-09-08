import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/models/medical_history_model.dart';
import 'package:rescuein/theme/theme.dart';

// Mengubah dari StatelessWidget ke StatefulWidget
class MedicalHistoryScreen extends StatefulWidget {
  final MedicalHistoryModel medicalHistory;

  const MedicalHistoryScreen({super.key, required this.medicalHistory});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  // State untuk mengontrol mode edit
  bool _isEditing = false;

  // State untuk menampung data yang sedang diedit
  late List<String> _selectedAllergies;
  late List<String> _selectedMedicalConditions;
  late List<String> _selectedMedications;
  late TextEditingController _additionalNotesController;

  // Opsi pilihan yang sama seperti di halaman signup
  final List<String> _allergyOptions = [
    'Tidak ada alergi', 'Makanan laut', 'Kacang-kacangan', 'Susu', 'Telur',
    'Antibiotik', 'Aspirin', 'Debu', 'Serbuk sari', 'Bulu hewan', 'Lainnya'
  ];
  final List<String> _medicalConditionOptions = [
    'Tidak ada riwayat penyakit', 'Diabetes', 'Hipertensi', 'Jantung', 'Asma',
    'Stroke', 'Kolesterol tinggi', 'Ginjal', 'Liver', 'Tiroid', 'Kanker', 'Lainnya'
  ];
  final List<String> _medicationOptions = [
    'Tidak konsumsi obat rutin', 'Insulin', 'Obat tekanan darah', 'Obat jantung',
    'Inhaler asma', 'Obat kolesterol', 'Vitamin', 'Suplemen', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi state dengan data awal saat widget pertama kali dibuat
    _initializeState(widget.medicalHistory);
  }

  // Fungsi untuk mengisi state lokal dari model
  void _initializeState(MedicalHistoryModel medicalHistory) {
    _selectedAllergies = List.from(medicalHistory.alergi);
    _selectedMedicalConditions = List.from(medicalHistory.riwayatPenyakit);
    _selectedMedications = List.from(medicalHistory.obatRutin);
    _additionalNotesController =
        TextEditingController(text: medicalHistory.catatanTambahan);
  }

  @override
  void dispose() {
    _additionalNotesController.dispose();
    super.dispose();
  }

  // Fungsi yang dipanggil saat tombol 'Simpan' ditekan
  void _handleSaveChanges() {
    final updatedHistory = MedicalHistoryModel(
      alergi: _selectedAllergies,
      riwayatPenyakit: _selectedMedicalConditions,
      obatRutin: _selectedMedications,
      catatanTambahan: _additionalNotesController.text.trim(),
    );
    // Kirim event ke BLoC untuk memperbarui data
    context
        .read<ProfileBloc>()
        .add(UpdateMedicalHistory(updatedMedicalHistory: updatedHistory));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? errorColor : successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // BlocListener untuk merespon perubahan state dari ProfileBloc
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          setState(() => _isEditing = false); // Kembali ke mode tampilan
          _showSnackBar('Data medis berhasil diperbarui.');
        } else if (state is ProfileFailure) {
          _showSnackBar(state.message, isError: true);
        } else if (state is ProfileLoaded) {
          // Jika data dimuat ulang, perbarui state lokal
          _initializeState(state.medicalHistory);
        }
      },
      child: Scaffold(
        backgroundColor: surfaceColor,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          // Tampilkan view yang sesuai berdasarkan mode edit
          child: _isEditing ? _buildEditView() : _buildDisplayView(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Riwayat Medis',
        style: headingMediumTextStyle.copyWith(color: whiteColor),
      ),
      backgroundColor: primaryColor,
      elevation: 2,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: primaryGradient)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Tombol dinamis: 'Edit' atau 'Simpan'
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileUpdateInProgress) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white)),
              );
            }
            return TextButton(
              onPressed: () {
                if (_isEditing) {
                  _handleSaveChanges();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(
                _isEditing ? 'Simpan' : 'Edit',
                style: buttonMediumTextStyle.copyWith(color: Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- WIDGET UNTUK MODE TAMPILAN (DISPLAY) ---
  Widget _buildDisplayView() {
    // Menggunakan state terbaru dari ProfileBloc jika ada, jika tidak, dari widget
    final currentState = context.read<ProfileBloc>().state;
    final displayHistory = currentState is ProfileLoaded
        ? currentState.medicalHistory
        : widget.medicalHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          context,
          icon: Icons.warning_amber_outlined,
          title: 'Alergi',
          items: displayHistory.alergi,
          noneMessage: 'Tidak ada data alergi.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          context,
          icon: Icons.medical_information_outlined,
          title: 'Riwayat Penyakit',
          items: displayHistory.riwayatPenyakit,
          noneMessage: 'Tidak ada data riwayat penyakit.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSectionCard(
          context,
          icon: Icons.medication_outlined,
          title: 'Obat Rutin',
          items: displayHistory.obatRutin,
          noneMessage: 'Tidak ada data konsumsi obat rutin.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildNotesCard(context, notes: displayHistory.catatanTambahan),
      ],
    );
  }

  // --- WIDGET UNTUK MODE EDIT ---
  Widget _buildEditView() {
    return Column(
      children: [
        _buildMedicalSection(
          title: 'Alergi',
          subtitle: 'Pilih alergi yang Anda miliki',
          icon: Icons.warning_amber_outlined,
          options: _allergyOptions,
          selectedItems: _selectedAllergies,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected.contains('Tidak ada alergi')) {
                _selectedAllergies = ['Tidak ada alergi'];
              } else {
                _selectedAllergies = selected..remove('Tidak ada alergi');
              }
            });
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildMedicalSection(
          title: 'Riwayat Penyakit',
          subtitle: 'Pilih penyakit yang pernah/sedang diderita',
          icon: Icons.medical_information_outlined,
          options: _medicalConditionOptions,
          selectedItems: _selectedMedicalConditions,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected.contains('Tidak ada riwayat penyakit')) {
                _selectedMedicalConditions = ['Tidak ada riwayat penyakit'];
              } else {
                _selectedMedicalConditions = selected..remove('Tidak ada riwayat penyakit');
              }
            });
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildMedicalSection(
          title: 'Obat yang Dikonsumsi',
          subtitle: 'Pilih obat yang rutin dikonsumsi saat ini',
          icon: Icons.medication_outlined,
          options: _medicationOptions,
          selectedItems: _selectedMedications,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected.contains('Tidak konsumsi obat rutin')) {
                _selectedMedications = ['Tidak konsumsi obat rutin'];
              } else {
                _selectedMedications = selected..remove('Tidak konsumsi obat rutin');
              }
            });
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildTextField(
          controller: _additionalNotesController,
          label: 'Catatan Tambahan (Opsional)',
          hint: 'Informasi kesehatan lain yang perlu diketahui...',
          prefixIcon: Icons.note_outlined,
          maxLines: 4,
        ),
      ],
    );
  }

  // --- WIDGET HELPER (diambil dari kode asli dan signup_screen) ---

  Widget _buildSectionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required List<String> items,
      required String noneMessage}) {
    // (Kode ini sama seperti yang Anda berikan, tidak ada perubahan)
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
            Divider(height: 1, color: borderColor),
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
                        Expanded(child: Text(item, style: bodyMediumTextStyle)),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, {required String notes}) {
    // (Kode ini sama seperti yang Anda berikan, tidak ada perubahan)
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
            Divider(height: 1, color: borderColor),
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
                notes.isEmpty
                    ? 'Tidak ada catatan tambahan.'
                    : notes,
                style: bodyMediumTextStyle.copyWith(
                  color: notes.isEmpty 
                      ? textSecondaryColor 
                      : textPrimaryColor,
                  height: 1.5,
                  fontStyle: notes.isEmpty 
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

  Widget _buildMedicalSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> options,
    required List<String> selectedItems,
    required Function(List<String>) onSelectionChanged,
  }) {
    // (Widget ini diadaptasi dari signup_screen.dart)
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: mediumRadius,
        border: Border.all(color: borderColor),
      ),
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
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: bodyLargeTextStyle.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: bodySmallTextStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options.map((option) {
              bool isSelected = selectedItems.contains(option);
              return GestureDetector(
                onTap: () {
                  List<String> newSelection = List.from(selectedItems);
                  if (isSelected) {
                    newSelection.remove(option);
                  } else {
                    newSelection.add(option);
                  }
                  onSelectionChanged(newSelection);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.1) : backgroundLight,
                    borderRadius: smallRadius,
                    border: Border.all(
                      color: isSelected ? primaryColor : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: bodySmallTextStyle.copyWith(
                      color: isSelected ? primaryColor : textSecondaryColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    // (Widget ini diadaptasi dari signup_screen.dart)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: bodyLargeTextStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: bodyMediumTextStyle.copyWith(color: textTertiaryColor),
            prefixIcon: Icon(prefixIcon, color: textTertiaryColor, size: 20),
            filled: true,
            fillColor: backgroundLight,
            border: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }
}