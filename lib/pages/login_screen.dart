import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/signup_screen.dart';
import 'package:rescuein/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.splash,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      _buildHeader(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildLoginForm(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildLoginButton(),
                      const SizedBox(height: AppSpacing.md),
                      _buildForgotPassword(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildDivider(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: backgroundLight,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [cardShadow],
          ),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Selamat Datang Kembali', style: headingLargeTextStyle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Masuk untuk mengakses fitur pertolongan pertama\ndan konsultasi kesehatan',
          style: bodyMediumTextStyle.copyWith(color: textSecondaryColor, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [lightShadow],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Masukkan email Anda',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Masukkan format email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Masukkan password Anda',
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
              return null;
            },
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: bodyMediumTextStyle.copyWith(fontWeight: FontWeight.w600, color: textPrimaryColor),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          ),
        ),
      ],
    );
  }

   Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // --- PERBAIKAN DI SINI ---
        // Loading akan aktif hanya jika state adalah AuthLoading.
        // Jika state adalah AuthFailure atau lainnya, loading akan berhenti.
        final isLoading = state is AuthLoading;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            // Jika sedang loading, buat gradien menjadi abu-abu. Jika tidak, gunakan gradien utama.
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isLoading ? [Colors.grey, Colors.grey.shade400] : primaryGradient,
            ),
            borderRadius: mediumRadius,
            boxShadow: [
              if (!isLoading) // Hanya tampilkan bayangan jika tidak sedang loading
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: mediumRadius),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: whiteColor, strokeWidth: 2),
                  )
                : Text('Masuk', style: buttonLargeTextStyle),
          ),
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
        },
        child: Text(
          'Lupa Password?',
          style: bodyMediumTextStyle.copyWith(color: primaryColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('ATAU', style: bodySmallTextStyle.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
        ),
        Expanded(child: Divider(color: borderColor, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: mediumRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Belum punya akun? ', style: bodyMediumTextStyle.copyWith(color: textSecondaryColor)),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: Text(
              'Daftar Sekarang',
              style: bodyMediumTextStyle.copyWith(color: primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}