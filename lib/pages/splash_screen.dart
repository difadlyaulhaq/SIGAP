import 'package:flutter/material.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppDurations.splash,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _rotateAnimation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    );
  }

  void _startAnimations() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _rotateController.repeat();
    });
  }

  void _navigateToNextScreen() {
    // --- PENYESUAIAN NAVIGASI ---
    // Menggunakan Navigator 1.0 (MaterialPageRoute) bukan go_router
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SplashContent(
            fadeAnimation: _fadeAnimation,
            scaleAnimation: _scaleAnimation,
            slideAnimation: _slideAnimation,
            rotateAnimation: _rotateAnimation,
          ),
        ),
      ),
    );
  }
}

class SplashContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> rotateAnimation;

  const SplashContent({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.slideAnimation,
    required this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: LogoImage(rotateAnimation: rotateAnimation),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: const AppTitleText(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FadeTransition(
          opacity: fadeAnimation,
          child: const LoadingIndicator(),
        ),
      ],
    );
  }
}

// --- PENYESUAIAN KONTEN ---
// Widget LogoImage disesuaikan untuk menampilkan ikon medis "Rescuein"
class LogoImage extends StatelessWidget {
  final Animation<double> rotateAnimation;

  const LogoImage({super.key, required this.rotateAnimation});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: rotateAnimation.value * 2 * 3.14159,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: whiteColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Image(
            image: AssetImage("assets/images/rescuein_logo.png"),
          ),
        ),
      ],
    );
  }
}

// --- PENYESUAIAN KONTEN ---
// Widget AppTitleText disesuaikan untuk menampilkan nama dan tagline "Rescuein"
class AppTitleText extends StatelessWidget {
  const AppTitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "SIGAP",
          style: modernWhiteTextStyle.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: smallRadius,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Your Personal First Aid Assistant",
          style: modernWhiteTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: whiteColor.withOpacity(0.9),
            letterSpacing: 0.25,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              accentColor.withOpacity(0.9),
            ),
            backgroundColor: whiteColor.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          "Loading...",
          style: modernWhiteTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: whiteColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}