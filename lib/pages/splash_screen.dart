import 'package:flutter/material.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/services/session_manager.dart';
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
  
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    
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

    _startAnimationsAndNavigation();
  }

  void _startAnimationsAndNavigation() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    if (_hasNavigated || !mounted) return;

    final bool isLoggedIn = await SessionManager.instance.isLoggedIn();
    
    if (isLoggedIn) {
      _navigateToScreen(const HomeScreen());
    } else {
      _navigateToScreen(const LoginScreen());
    }
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
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    final logoSize = screenWidth * 0.25;
    final titleFontSize = screenWidth * 0.12;
    final subtitleFontSize = screenWidth * 0.04;
    final loadingTextFontSize = screenWidth * 0.035;
    
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: isSmallScreen ? 1 : 2,
                            child: const SizedBox(),
                          ),
                          
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: logoSize.clamp(80.0, 160.0),
                                height: logoSize.clamp(80.0, 160.0),
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: isTablet ? 30 : 20,
                                      offset: Offset(0, isTablet ? 12 : 8),
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
                          
                          SizedBox(height: screenHeight * 0.05),
                          
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1,
                              ),
                              child: Text(
                                "SIGAP",
                                style: TextStyle(
                                  fontSize: titleFontSize.clamp(32.0, 64.0),
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.15,
                              ),
                              child: Text(
                                "Your Personal First Aid Assistant",
                                style: TextStyle(
                                  fontSize: subtitleFontSize.clamp(12.0, 20.0),
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
                          ),
                          
                          Flexible(
                            flex: isSmallScreen ? 1 : 3,
                            child: SizedBox(height: screenHeight * 0.1),
                          ),
                          
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.08,
                                  height: screenWidth * 0.08,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                                    strokeWidth: isTablet ? 4.0 : 3.0,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                Text(
                                  "Memuat aplikasi...",
                                  style: TextStyle(
                                    color: whiteColor.withOpacity(0.8),
                                    fontSize: loadingTextFontSize.clamp(10.0, 18.0),
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Flexible(
                            flex: 1,
                            child: const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}