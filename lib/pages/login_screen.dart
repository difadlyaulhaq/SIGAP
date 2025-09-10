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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    final logoSize = isTablet
        ? 180.0
        : (screenWidth * 0.35).clamp(120.0, 160.0);
    final horizontalPadding = isTablet ? screenWidth * 0.25 : AppSpacing.lg;
    final formMaxWidth = isTablet ? 500.0 : double.infinity;

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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: formMaxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // SizedBox(
                          //   height: isSmallScreen
                          //       ? AppSpacing.lg
                          //       : AppSpacing.xxl,
                          // ),
                          _buildHeader(logoSize, isTablet),
                          SizedBox(
                            height: isSmallScreen
                                ? AppSpacing.lg
                                : AppSpacing.xxl,
                          ),
                          _buildLoginForm(screenWidth),
                          const SizedBox(height: AppSpacing.lg),
                          _buildLoginButton(),
                          // const SizedBox(height: AppSpacing.md),
                          // _buildForgotPassword(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildDivider(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildRegisterLink(),
                          // SizedBox(
                          //   height: isSmallScreen
                          //       ? AppSpacing.md
                          //       : AppSpacing.lg,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double logoSize, bool isTablet) {
    final titleFontSize = isTablet ? 35.0 : 28.0;
    final subtitleFontSize = isTablet ? 18.0 : 16.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: backgroundLight,
            borderRadius: BorderRadius.circular(isTablet ? 35 : 25),
            boxShadow: [cardShadow],
          ),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        SizedBox(height: isTablet ? AppSpacing.lg : AppSpacing.md),
        Text(
          'Selamat Datang ',
          style: headingLargeTextStyle.copyWith(fontSize: titleFontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? AppSpacing.md : AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? AppSpacing.xxl : AppSpacing.lg,
          ),
          child: Text(
            'Masuk untuk mengakses fitur pertolongan pertama\ndan konsultasi kesehatan',
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
              height: 1.5,
              fontSize: subtitleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(double screenWidth) {
    final fieldSpacing = screenWidth > 600 ? AppSpacing.lg : AppSpacing.md;
    final formPadding = screenWidth > 600 ? AppSpacing.xxl : AppSpacing.lg;

    return Container(
      padding: EdgeInsets.all(formPadding),
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
          SizedBox(height: fieldSpacing),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final fieldHeight = isTablet ? 60.0 : 56.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: bodyMediumTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
            fontSize: fontSize,
          ),
        ),
        SizedBox(height: isTablet ? AppSpacing.md : AppSpacing.sm),
        SizedBox(
          height: fieldHeight,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            style: bodyLargeTextStyle.copyWith(fontSize: fontSize),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: bodyMediumTextStyle.copyWith(
                color: textTertiaryColor,
                fontSize: fontSize * 0.9,
              ),
              prefixIcon: Icon(prefixIcon, color: textTertiaryColor),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: backgroundLight,
              border: OutlineInputBorder(
                borderRadius: mediumRadius,
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: mediumRadius,
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: mediumRadius,
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: isTablet ? AppSpacing.lg : AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;
        final buttonHeight = isTablet ? 64.0 : 56.0;
        final fontSize = isTablet ? 20.0 : 18.0;

        return Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isLoading
                  ? [Colors.grey, Colors.grey.shade400]
                  : primaryGradient,
            ),
            borderRadius: mediumRadius,
            boxShadow: [
              if (!isLoading)
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
                    width: isTablet ? 28 : 24,
                    height: isTablet ? 28 : 24,
                    child: CircularProgressIndicator(
                      color: whiteColor,
                      strokeWidth: isTablet ? 3 : 2,
                    ),
                  )
                : Text(
                    'Masuk',
                    style: buttonLargeTextStyle.copyWith(fontSize: fontSize),
                  ),
          ),
        );
      },
    );
  }


  Widget _buildDivider() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final fontSize = isTablet ? 14.0 : 12.0;

    return Row(
      children: [
        Expanded(child: Divider(color: borderColor, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? AppSpacing.lg : AppSpacing.md,
          ),
          child: Text(
            'ATAU',
            style: bodySmallTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(child: Divider(color: borderColor, thickness: 1)),
      ],
    );
  }

  Widget _buildRegisterLink() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final fontSize = isTablet ? 16.0 : 14.0;
    final padding = isTablet ? AppSpacing.lg : AppSpacing.md;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: mediumRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Belum punya akun? ',
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
              fontSize: fontSize,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            child: Text(
              'Daftar Sekarang',
              style: bodyMediumTextStyle.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
