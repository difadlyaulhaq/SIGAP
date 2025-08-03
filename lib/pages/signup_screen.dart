import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/theme/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  // State variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  int _currentStep = 0;
  String _selectedGender = '';
  DateTime? _selectedDate;
  String _selectedBloodType = '';

  // Medical history variables
  List<String> _selectedAllergies = [];
  List<String> _selectedMedicalConditions = [];
  List<String> _selectedMedications = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _allergyOptions = [
    'Tidak ada alergi',
    'Makanan laut',
    'Kacang-kacangan',
    'Susu',
    'Telur',
    'Antibiotik',
    'Aspirin',
    'Debu',
    'Serbuk sari',
    'Bulu hewan',
    'Lainnya'
  ];
  final List<String> _medicalConditionOptions = [
    'Tidak ada riwayat penyakit',
    'Diabetes',
    'Hipertensi',
    'Jantung',
    'Asma',
    'Stroke',
    'Kolesterol tinggi',
    'Ginjal',
    'Liver',
    'Tiroid',
    'Kanker',
    'Lainnya'
  ];
  final List<String> _medicationOptions = [
    'Tidak konsumsi obat rutin',
    'Insulin',
    'Obat tekanan darah',
    'Obat jantung',
    'Inhaler asma',
    'Obat kolesterol',
    'Vitamin',
    'Suplemen',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _alamatController.dispose();
    _emergencyContactController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender.isEmpty ||
        _selectedDate == null ||
        _selectedBloodType.isEmpty ||
        _selectedAllergies.isEmpty ||
        _selectedMedicalConditions.isEmpty ||
        _selectedMedications.isEmpty) {
      _showSnackBar('Harap lengkapi semua data pada setiap langkah.', isError: true);
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Harap setujui syarat dan ketentuan untuk mendaftar.', isError: true);
      return;
    }

    context.read<AuthBloc>().add(AuthSignupRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nama: _namaController.text.trim(),
          jenisKelamin: _selectedGender,
          tanggalLahir: _selectedDate!,
          telepon: _phoneController.text.trim(),
          alamat: _alamatController.text.trim(),
          golonganDarah: _selectedBloodType,
          kontakDarurat: _emergencyContactController.text.trim(),
          alergi: _selectedAllergies,
          riwayatPenyakit: _selectedMedicalConditions,
          obatRutin: _selectedMedications,
          catatanTambahan: _additionalNotesController.text.trim(),
        ));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle_outline, size: 50, color: successColor),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Registrasi Berhasil!', style: headingMediumTextStyle.copyWith(color: successColor), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Akun Anda telah berhasil dibuat. Silakan login untuk mulai menggunakan aplikasi.',
                style: bodyMediumTextStyle.copyWith(
                    color: textSecondaryColor, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: mediumRadius),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text('Login Sekarang', style: buttonMediumTextStyle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: smallRadius),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: AppDurations.medium,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _showSuccessDialog();
          } else if (state is AuthFailure) {
            _showSnackBar(state.message, isError: true);
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildPersonalInfoStep(),
                          _buildMedicalInfoStep(),
                          _buildMedicalHistoryStep(),
                          _buildAccountStep(),
                        ],
                      ),
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios, color: textPrimaryColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daftar Akun Baru', style: headingMediumTextStyle),
                Text('Langkah ${_currentStep + 1} dari 4',
                    style: bodySmallTextStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? AppSpacing.sm : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Pribadi', style: headingSmallTextStyle),
          Text(
            'Masukkan data pribadi Anda dengan benar',
            style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildTextField(
            controller: _namaController,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap Anda',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildGenderSelector(),
          const SizedBox(height: AppSpacing.md),
          _buildDatePicker(),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _phoneController,
            label: 'Nomor Telepon',
            hint: 'Masukkan nomor telepon',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              if (value.length < 10) {
                return 'Nomor telepon minimal 10 digit';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _alamatController,
            label: 'Alamat',
            hint: 'Masukkan alamat lengkap',
            prefixIcon: Icons.location_on_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat tidak boleh kosong';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Medis', style: headingSmallTextStyle),
          Text(
            'Data ini penting untuk memberikan pertolongan yang tepat',
            style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildBloodTypeSelector(),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _emergencyContactController,
            label: 'Kontak Darurat',
            hint: 'Nomor telepon keluarga/kerabat terdekat',
            prefixIcon: Icons.emergency_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kontak darurat tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: infoColor.withOpacity(0.1),
              borderRadius: mediumRadius,
              border: Border.all(color: infoColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: infoColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Informasi medis ini akan membantu kami memberikan saran kesehatan yang lebih akurat.',
                    style: bodySmallTextStyle.copyWith(color: infoColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Riwayat Kesehatan', style: headingSmallTextStyle),
          Text(
            'Data riwayat kesehatan untuk memberikan pertolongan yang tepat',
            style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
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
                  _selectedAllergies = selected;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
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
                  _selectedMedicalConditions = selected;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
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
                  _selectedMedications = selected;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildTextField(
            controller: _additionalNotesController,
            label: 'Catatan Tambahan (Opsional)',
            hint: 'Informasi kesehatan lain yang perlu diketahui...',
            prefixIcon: Icons.note_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buat Akun', style: headingSmallTextStyle),
          Text(
            'Buat email dan password untuk akun Anda',
            style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Masukkan alamat email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Minimal 8 karakter',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: textTertiaryColor,
              ),
              onPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Password minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password',
            hint: 'Masukkan ulang password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: textTertiaryColor,
              ),
              onPressed: () {
                setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              if (value != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: mediumRadius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() => _agreeToTerms = value ?? false);
                  },
                  activeColor: primaryColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saya setuju dengan syarat dan ketentuan', style: bodyMediumTextStyle),
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () {
                          // Show terms and conditions
                        },
                        child: Text(
                          'Baca syarat dan ketentuan',
                          style: bodySmallTextStyle.copyWith(
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    TextInputType? keyboardType,
    bool isPassword = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    bool obscureText = false;
    if (isPassword) {
      if (controller == _passwordController) {
        obscureText = !_isPasswordVisible;
      } else if (controller == _confirmPasswordController) {
        obscureText = !_isConfirmPasswordVisible;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: bodyLargeTextStyle,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: bodyMediumTextStyle.copyWith(color: textTertiaryColor),
            prefixIcon: Icon(prefixIcon, color: textTertiaryColor),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: backgroundLight,
            border: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: primaryColor, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: mediumRadius, borderSide: BorderSide(color: errorColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jenis Kelamin', style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _genderOptions.map((gender) {
            bool isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  margin: EdgeInsets.only(
                      right: gender != _genderOptions.last ? AppSpacing.sm : 0),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.1)
                        : backgroundLight,
                    borderRadius: mediumRadius,
                    border: Border.all(
                      color: isSelected ? primaryColor : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    gender,
                    textAlign: TextAlign.center,
                    style: bodyMediumTextStyle.copyWith(
                      color: isSelected ? primaryColor : textSecondaryColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tanggal Lahir', style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: backgroundLight,
              borderRadius: mediumRadius,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: textTertiaryColor),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Pilih tanggal lahir',
                  style: bodyMediumTextStyle.copyWith(
                    color: _selectedDate != null
                        ? textPrimaryColor
                        : textTertiaryColor,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: textTertiaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Golongan Darah', style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _bloodTypes.map((bloodType) {
            bool isSelected = _selectedBloodType == bloodType;
            return GestureDetector(
              onTap: () => setState(() => _selectedBloodType = bloodType),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : backgroundLight,
                  borderRadius: smallRadius,
                  border: Border.all(
                    color: isSelected ? primaryColor : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  bloodType,
                  style: bodyMediumTextStyle.copyWith(
                    color: isSelected ? primaryColor : textSecondaryColor,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
                    Text(title,
                        style: bodyLargeTextStyle.copyWith(
                            fontWeight: FontWeight.w600)),
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
              bool isNoneOption =
                  option.contains('Tidak ada') || option.contains('tidak');
              return GestureDetector(
                onTap: () {
                  List<String> newSelection = List.from(selectedItems);
                  if (isNoneOption) {
                    newSelection = [option];
                  } else {
                    if (isSelected) {
                      newSelection.remove(option);
                    } else {
                      newSelection.removeWhere((item) =>
                          item.contains('Tidak ada') || item.contains('tidak'));
                      newSelection.add(option);
                    }
                  }
                  onSelectionChanged(newSelection);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isNoneOption
                            ? accentColor.withOpacity(0.1)
                            : primaryColor.withOpacity(0.1))
                        : backgroundLight,
                    borderRadius: smallRadius,
                    border: Border.all(
                      color: isSelected
                          ? (isNoneOption ? accentColor : primaryColor)
                          : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: bodySmallTextStyle.copyWith(
                      color: isSelected
                          ? (isNoneOption ? accentColor : primaryColor)
                          : textSecondaryColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedItems.isNotEmpty &&
              selectedItems.any(
                  (item) => !item.contains('Tidak ada') && !item.contains('tidak')))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: smallRadius,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: warningColor, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Terpilih: ${selectedItems.where((item) => !item.contains('Tidak ada') && !item.contains('tidak')).length} item',
                        style: bodySmallTextStyle.copyWith(
                          color: warningColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _previousStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text('Sebelumnya',
                        style:
                            buttonMediumTextStyle.copyWith(color: textSecondaryColor)),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: _currentStep == 0 ? 1 : 1,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: primaryGradient),
                    borderRadius: mediumRadius,
                    boxShadow: [
                      BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : (_currentStep == 3 ? _handleSignup : _nextStep),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
                    ),
                    child: isLoading
                        ?  SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: whiteColor, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == 3 ? 'Daftar' : 'Selanjutnya',
                            style: buttonLargeTextStyle,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}