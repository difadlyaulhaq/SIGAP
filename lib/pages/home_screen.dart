import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/article/article_bloc.dart';
import 'package:rescuein/bloc/article/article_event.dart';
import 'package:rescuein/bloc/article/article_state.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/models/article_model.dart';
import 'package:rescuein/pages/hospital_nearby_screen.dart';
import 'package:rescuein/pages/emergency_screen.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/services/news_api_service.dart';
import 'package:rescuein/services/session_manager.dart';
import 'package:url_launcher/url_launcher.dart';

// FIX: Tambahkan import untuk AuthState dan turunannya
import 'package:rescuein/bloc/auth/auth_state.dart';

import '../theme/theme.dart' as theme;
import 'chatbot_screen.dart';
import 'profile_screen.dart';

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MainFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final String badge;
  final VoidCallback onTap;

  _MainFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    this.badge = '',
    required this.onTap,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // STRUKTUR YANG LEBIH BAIK:
    // 1. MultiBlocProvider untuk menyediakan semua BLoC yang dibutuhkan halaman ini.
    // 2. BlocListener untuk mereaksi perubahan state AuthBloc.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) =>
              ArticleBloc(NewsApiService())..add(FetchArticles()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Panggil fetch data profil setelah user terautentikasi
            context.read<ProfileBloc>().add(FetchProfileData());
          } else if (state is AuthUnauthenticated) {
            // Arahkan ke login jika sesi berakhir saat di halaman ini
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        },
        child: const _HomeScreenView(),
      ),
    );
  }
}

// Tidak ada perubahan di bawah baris ini.
// Sisa kode dari _HomeScreenView dan HomePageContent sudah benar.
// ... (sisa kode Anda dari _HomeScreenView ke bawah) ...
class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView();

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    if (_pageIndex != index) {
      setState(() => _pageIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _safeNavigate(String routeName) {
    if (!mounted) return;
    try {
      Navigator.pushNamed(context, routeName);
    } catch (e) {
      print('Navigation error to $routeName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final double fabSize = isLargeScreen ? 72.0 : 60.0;
    final double navBarHeight = isLargeScreen ? 80.0 : 70.0;
    final double notchMargin = isLargeScreen ? 12.0 : 10.0;

    return Scaffold(
      backgroundColor: theme.backgroundLight,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _pageIndex = index);
          },
          children: [
            HomePageContent(onNavigate: _onNavigationTap),
            const HospitalNearbyPage(),
            const ChatbotScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _safeNavigate('/detect'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: fabSize * 0.5,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: notchMargin,
          height: navBarHeight,
          color: theme.whiteColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                icon: Icons.home_rounded,
                index: 0,
                isLargeScreen: isLargeScreen,
              ),
              _buildNavItem(
                icon: Icons.local_hospital_rounded,
                index: 1,
                isLargeScreen: isLargeScreen,
              ),
              SizedBox(width: fabSize),
              _buildNavItem(
                icon: Icons.chat_bubble_rounded,
                index: 2,
                isLargeScreen: isLargeScreen,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                index: 3,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isLargeScreen,
  }) {
    final bool isSelected = _pageIndex == index;
    final double iconSize =
        isLargeScreen ? (isSelected ? 32 : 28) : (isSelected ? 28 : 24);
    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? theme.primaryColor : theme.textTertiaryColor,
          size: iconSize,
        ),
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final void Function(int) onNavigate;

  const HomePageContent({super.key, required this.onNavigate});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _loadUserDataFromLocal();
  }

  Future<void> _loadUserDataFromLocal() async {
    final user = await SessionManager.instance.getUserData();
    if (user != null && mounted) {
      setState(() {
        _userName = user.nama.split(' ').first;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToEmergencyScreen() {
    if (!mounted) return;
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileBloc,
          child: const EmergencyScreen(),
        ),
      ),
    );
  }

  void _safeNavigate(String routeName) {
    if (!mounted) return;
    try {
      Navigator.pushNamed(context, routeName);
    } catch (e) {
      print('Navigation error to $routeName: $e');
    }
  }

  List<_QuickAction> _getQuickActions() {
    return [
      _QuickAction(
        icon: Icons.local_hospital_rounded,
        label: 'Rumah Sakit',
        color: Colors.blue,
        onTap: () => widget.onNavigate(1),
      ),
      _QuickAction(
        icon: Icons.chat_rounded,
        label: 'Chat AI',
        color: Colors.green,
        onTap: () => widget.onNavigate(2),
      ),
      _QuickAction(
        icon: Icons.article_rounded,
        label: 'Artikel',
        color: Colors.orange,
        onTap: () => _safeNavigate('/articles'),
      ),
    ];
  }

  List<_MainFeature> _getMainFeatures() {
    return [
      _MainFeature(
        icon: Icons.camera_alt_rounded,
        title: 'Deteksi Luka',
        description: 'Scan luka dan dapatkan panduan P3K yang tepat',
        primaryColor: const Color(0xFF6366F1),
        secondaryColor: const Color(0xFF8B5CF6),
        badge: 'AI',
        onTap: () => _safeNavigate('/detect'),
      ),
      _MainFeature(
        icon: Icons.school_rounded,
        title: 'Belajar P3K',
        description: 'Pelajari pertolongan pertama dengan metode interaktif',
        primaryColor: const Color(0xFF10B981),
        secondaryColor: const Color(0xFF059669),
        badge: 'NEW',
        onTap: () => _safeNavigate('/learning'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLargeScreen = screenSize.width > 600;
    final double hPadding = screenSize.width * 0.05;
    final double vPadding = isLargeScreen ? 24.0 : 16.0;

    final quickActions = _getQuickActions();
    final mainFeatures = _getMainFeatures();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  String userName = _userName;
                  if (state is ProfileLoaded) {
                    userName = state.user.nama.split(' ').first;
                  }
                  return _buildModernHeader(
                    userName,
                    hPadding,
                    vPadding,
                    isLargeScreen,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _buildEmergencyBanner(hPadding, vPadding, isLargeScreen),
            ),
            SliverToBoxAdapter(
              child: _buildQuickActionsSection(
                quickActions,
                hPadding,
                vPadding,
                isLargeScreen,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildMainFeaturesSection(
                mainFeatures,
                hPadding,
                vPadding,
                isLargeScreen,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildHealthTipsSection(hPadding, vPadding, isLargeScreen),
            ),
            SliverToBoxAdapter(
              child: _buildArticlesSectionHeader(hPadding, isLargeScreen),
            ),
            SliverToBoxAdapter(
              child: _buildArticlesSectionBody(screenSize, hPadding),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(
    String userName,
    double hPadding,
    double vPadding,
    bool isLargeScreen,
  ) {
    final hour = DateTime.now().hour;
    String greeting;
    String subtitle;
    Color gradientStart, gradientEnd;

    if (hour < 12) {
      greeting = 'Selamat Pagi, $userName!';
      subtitle = 'Mulai hari dengan persiapan yang baik';
      gradientStart = const Color(0xFF4F46E5);
      gradientEnd = const Color(0xFF7C3AED);
    } else if (hour < 17) {
      greeting = 'Selamat Siang, $userName!';
      subtitle = 'Tetap waspada dan siap siaga';
      gradientStart = const Color(0xFF0EA5E9);
      gradientEnd = const Color(0xFF3B82F6);
    } else {
      greeting = 'Selamat Malam, $userName!';
      subtitle = 'Istirahat yang cukup untuk kesehatan';
      gradientStart = const Color(0xFF1E40AF);
      gradientEnd = const Color(0xFF3730A3);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 30 : 24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 30 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isLargeScreen ? 18 : 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: isLargeScreen ? 40 : 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyBanner(
    double hPadding,
    double vPadding,
    bool isLargeScreen,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(hPadding, 0, hPadding, vPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
          onTap: () => _navigateToEmergencyScreen(),
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      isLargeScreen ? 16 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.emergency_rounded,
                    color: Colors.white,
                    size: isLargeScreen ? 32 : 28,
                  ),
                ),
                SizedBox(width: isLargeScreen ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh Bantuan Darurat?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Akses cepat nomor darurat & keluarga',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isLargeScreen ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(
    List<_QuickAction> actions,
    double hPadding,
    double vPadding,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Row(
            children: actions
                .map(
                  (action) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: actions.indexOf(action) < actions.length - 1
                            ? (isLargeScreen ? 16 : 12)
                            : 0,
                      ),
                      child: _buildQuickActionCard(action, isLargeScreen),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action, bool isLargeScreen) {
    final double iconContainerSize = isLargeScreen ? 60 : 48;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
          onTap: action.onTap,
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
            child: Column(
              children: [
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      isLargeScreen ? 16 : 12,
                    ),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: iconContainerSize * 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFeaturesSection(
    List<_MainFeature> features,
    double hPadding,
    double vPadding,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitur Utama',
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          ...features.map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: isLargeScreen ? 20 : 16),
              child: _buildMainFeatureCard(feature, isLargeScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureCard(_MainFeature feature, bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [feature.primaryColor, feature.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: feature.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
          onTap: feature.onTap,
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            child: Row(
              children: [
                Container(
                  width: isLargeScreen ? 70 : 60,
                  height: isLargeScreen ? 70 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      isLargeScreen ? 20 : 16,
                    ),
                  ),
                  child: Icon(
                    feature.icon,
                    color: Colors.white,
                    size: isLargeScreen ? 36 : 30,
                  ),
                ),
                SizedBox(width: isLargeScreen ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            feature.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLargeScreen ? 20 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (feature.badge.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                feature.badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isLargeScreen ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection(
    double hPadding,
    double vPadding,
    bool isLargeScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips Kesehatan Hari Ini',
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isLargeScreen ? 20 : 16),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: isLargeScreen ? 56 : 48,
                  height: isLargeScreen ? 56 : 48,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(
                      isLargeScreen ? 16 : 12,
                    ),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.amber.shade700,
                    size: isLargeScreen ? 30 : 24,
                  ),
                ),
                SizedBox(width: isLargeScreen ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selalu Siap Siaga',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pastikan kotak P3K di rumah selalu lengkap dan mudah dijangkau saat darurat.',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 14,
                          color: Colors.black87,
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

  Widget _buildArticlesSectionHeader(double hPadding, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Artikel Kesehatan',
            style: TextStyle(
              fontSize: isLargeScreen ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _safeNavigate('/articles'),
            child: const Text('Lihat Semua'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSectionBody(Size screenSize, double hPadding) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading || state is ArticleInitial) {
          return _buildArticlePlaceholderList(screenSize, hPadding);
        } else if (state is ArticleLoaded) {
          return _buildArticleList(state.articles, screenSize, hPadding);
        } else if (state is ArticleError) {
          return _buildErrorMessage(hPadding);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildArticleList(
    List<Article> articles,
    Size screenSize,
    double hPadding,
  ) {
    final displayArticles =
        articles.length > 5 ? articles.take(5).toList() : articles;
    return SizedBox(
      height: screenSize.height * 0.28,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        scrollDirection: Axis.horizontal,
        itemCount: displayArticles.length,
        itemBuilder: (context, index) =>
            _buildArticleCard(displayArticles[index], screenSize),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildArticleCard(Article article, Size screenSize) {
    bool isLargeScreen = screenSize.width > 600;
    return SizedBox(
      width: screenSize.width * (isLargeScreen ? 0.4 : 0.7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _launchURL(article.url),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: _buildArticleImage(article),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isLargeScreen ? 16 : 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          article.sourceName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage(Article article) {
    if (article.urlToImage != null) {
      return Image.network(
        article.urlToImage!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _buildArticlePlaceholderList(Size screenSize, double hPadding) {
    return SizedBox(
      height: screenSize.height * 0.28,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) =>
            _buildArticleCardPlaceholder(screenSize),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildArticleCardPlaceholder(Size screenSize) {
    bool isLargeScreen = screenSize.width > 600;
    return SizedBox(
      width: screenSize.width * (isLargeScreen ? 0.4 : 0.7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      color: Colors.grey.shade300,
                    ),
                    const Spacer(),
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(double hPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat artikel',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Coba lagi nanti',
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!mounted) return;
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $url')),
        );
      }
    } catch (e) {
      print('URL launch error: $e');
    }
  }
}