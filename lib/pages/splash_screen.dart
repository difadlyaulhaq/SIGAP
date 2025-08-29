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
  
  bool _hasNavigated = false; // Flag untuk mencegah navigasi berulang

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi animasi
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200), 
      vsync: this
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController, 
      curve: Curves.easeIn
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController, 
      curve: Curves.elasticOut
    );

    // Mulai animasi
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    
    // PERBAIKAN UTAMA: Trigger manual check auth setelah delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_hasNavigated) {
        print('Triggering AuthCheckRequested from SplashScreen'); // Debug log
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _navigateToScreen(Widget screen) {
    if (_hasNavigated || !mounted) return;
    
    _hasNavigated = true;
    print('Navigating to: ${screen.runtimeType}'); // Debug log
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('AuthState changed to: ${state.runtimeType}'); // Debug log
        
        // Navigasi hanya setelah proses checking selesai
        if (state is AuthAuthenticated) {
          _navigateToScreen(const HomeScreen());
        } else if (state is AuthUnauthenticated) {
          _navigateToScreen(const LoginScreen());
        } else if (state is AuthFailure) {
          // Jika ada error, arahkan ke login
          _navigateToScreen(const LoginScreen());
        }
      },
      child: Scaffold(
        backgroundColor: surfaceColor, // Gunakan tema yang konsisten
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
                // Logo dengan animasi scale dan fade
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(16),
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
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Judul aplikasi
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "SIGAP",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: whiteColor,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Subtitle
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Your Personal First Aid Assistant",
                    style: TextStyle(
                      fontSize: 16,
                      color: whiteColor.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl * 2),
                
                // Loading indicator dengan animasi
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                          strokeWidth: 3.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Memuat aplikasi...",
                        style: TextStyle(
                          color: whiteColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}