import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Inisialisasi animasi untuk tampilan visual
    _fadeController = AnimationController(duration: AppDurations.medium, vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    // Memulai animasi
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _fadeController.forward());
    
    // TIDAK ADA LAGI NAVIGASI BERBASIS TIMER DI SINI
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMPLEMENTASI: Menggunakan BlocListener untuk menangani logika navigasi
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Logika navigasi dipindahkan ke sini, bereaksi terhadap perubahan state
        if (state is AuthAuthenticated) {
          // Jika BLoC bilang sudah login, arahkan ke HomeScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else if (state is AuthUnauthenticated) {
          // Jika BLoC bilang belum login, arahkan ke LoginScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        // Saat state AuthLoading atau AuthInitial, biarkan splash screen tetap tampil
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        shape: BoxShape.circle,
                        boxShadow: [strongShadow],
                      ),
                      child: const Image(image: AssetImage('assets/logo.png')),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "SIGAP",
                    style: modernWhiteTextStyle.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Your Personal First Aid Assistant",
                    style: modernWhiteTextStyle.copyWith(
                      color: whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                 CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                  strokeWidth: 2.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}