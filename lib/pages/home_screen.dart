import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/article/article_bloc.dart';
import 'package:rescuein/bloc/article/article_event.dart';
import 'package:rescuein/bloc/article/article_state.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/models/article_model.dart';

import 'package:rescuein/pages/hospital_nearby_screen.dart';
import 'package:rescuein/pages/emergency_screen.dart'; // <-- IMPORT DITAMBAHKAN
import 'package:rescuein/services/news_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme.dart' as theme;
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// Model untuk quick actions
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

// Model untuk menu utama
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

// Widget utama
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          )..add(FetchProfileData()),
        ),
        BlocProvider(
          create: (context) =>
              ArticleBloc(NewsApiService())..add(FetchArticles()),
        ),
      ],
      child: const _HomeScreenView(),
    );
  }
}

// View utama dengan PageView dan BottomAppBar
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _onNavigationTap(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: theme.backgroundLight,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _pageIndex = index);
          _tabController.index = index;
        },
        children: const [
          HomePageContent(),
          HospitalNearbyPage(),
          ChatbotScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: Container(
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
          onPressed: () {
            try {
              Navigator.pushNamed(context, '/detect');
            } catch (e) {
              print('Navigation error: $e');
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
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
          notchMargin: 10.0,
          height: 70.0,
          color: theme.whiteColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(icon: Icons.home_rounded, index: 0),
              _buildNavItem(icon: Icons.local_hospital_rounded, index: 1),
              const SizedBox(width: 48),
              _buildNavItem(icon: Icons.chat_bubble_rounded, index: 2),
              _buildNavItem(icon: Icons.person_rounded, index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _pageIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? theme.primaryColor : theme.textTertiaryColor,
        size: isSelected ? 28 : 24,
      ),
    );
  }
}

// KONTEN HALAMAN UTAMA
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _navigateToEmergencyScreen() {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileBloc,
          child: const EmergencyContactScreen(),
        ),
      ),
    );
  }

  List<_QuickAction> _getQuickActions() {
    return [
      _QuickAction(
        icon: Icons.phone_in_talk_rounded,
        label: 'Darurat',
        color: Colors.red,
        onTap: () => _navigateToEmergencyScreen(),
      ),
      _QuickAction(
        icon: Icons.local_hospital_rounded,
        label: 'Rumah Sakit',
        color: Colors.blue,
        onTap: () {
          final homeState =
              context.findAncestorStateOfType<_HomeScreenViewState>();
          homeState?._onNavigationTap(1);
        },
      ),
      _QuickAction(
        icon: Icons.chat_rounded,
        label: 'Chat AI',
        color: Colors.green,
        onTap: () {
          final homeState =
              context.findAncestorStateOfType<_HomeScreenViewState>();
          homeState?._onNavigationTap(2);
        },
      ),
      _QuickAction(
        icon: Icons.article_rounded,
        label: 'Artikel',
        color: Colors.orange,
        onTap: () {
          try {
            Navigator.pushNamed(context, '/articles');
          } catch (e) {
            print('Navigation error: $e');
          }
        },
      ),
    ];
  }
  
  // =======================================================================
  // === PERUBAHAN SELESAI DI SINI ===
  // =======================================================================


  List<_MainFeature> _getMainFeatures() {
    return [
      _MainFeature(
        icon: Icons.camera_alt_rounded,
        title: 'Deteksi Luka',
        description: 'Scan luka dan dapatkan panduan P3K yang tepat',
        primaryColor: const Color(0xFF6366F1),
        secondaryColor: const Color(0xFF8B5CF6),
        badge: 'AI',
        onTap: () {
          try {
            Navigator.pushNamed(context, '/detect');
          } catch (e) {
            print('Navigation error: $e');
          }
        },
      ),
      _MainFeature(
        icon: Icons.school_rounded,
        title: 'Belajar P3K',
        description: 'Pelajari pertolongan pertama dengan metode interaktif',
        primaryColor: const Color(0xFF10B981),
        secondaryColor: const Color(0xFF059669),
        badge: 'NEW',
        onTap: () {
          try {
            Navigator.pushNamed(context, '/learning');
          } catch (e) {
            print('Navigation error: $e');
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final quickActions = _getQuickActions();
    final mainFeatures = _getMainFeatures();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom Header
            SliverToBoxAdapter(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  String userName = 'Pengguna';
                  if (state is ProfileLoaded) {
                    userName = state.user.nama.split(' ').first;
                  }
                  return _buildModernHeader(userName);
                },
              ),
            ),

            // Emergency Alert Banner
            SliverToBoxAdapter(
              child: _buildEmergencyBanner(),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActionsSection(quickActions),
            ),

            // Main Features
            SliverToBoxAdapter(
              child: _buildMainFeaturesSection(mainFeatures),
            ),

            // Health Tips Section
            SliverToBoxAdapter(
              child: _buildHealthTipsSection(),
            ),

            // Articles Section
            SliverToBoxAdapter(
              child: _buildArticlesSectionHeader(),
            ),

            SliverToBoxAdapter(
              child: _buildArticlesSectionBody(),
            ),

            // Bottom spacing for FAB
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    String subtitle;
    Color gradientStart;
    Color gradientEnd;

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
      margin: const EdgeInsets.all(theme.AppSpacing.lg),
      padding: const EdgeInsets.all(theme.AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // === PERUBAHAN DI SINI ===
  // =======================================================================
  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          theme.AppSpacing.lg, 0, theme.AppSpacing.lg, theme.AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEmergencyScreen(),
          child: Padding(
            padding: const EdgeInsets.all(theme.AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.emergency_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: theme.AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Butuh Bantuan Darurat?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Akses cepat nomor darurat & keluarga',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
  // =======================================================================
  // === PERUBAHAN SELESAI ===
  // =======================================================================


  Widget _buildQuickActionsSection(List<_QuickAction> actions) {
    return Container(
      margin: const EdgeInsets.all(theme.AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: theme.AppSpacing.md),
          Row(
            children: actions
                .map((action) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right:
                              actions.indexOf(action) < actions.length - 1 ? 12 : 0,
                        ),
                        child: _buildQuickActionCard(action),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return Container(
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
          onTap: action.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildMainFeaturesSection(List<_MainFeature> features) {
    return Container(
      margin: const EdgeInsets.all(theme.AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitur Utama',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: theme.AppSpacing.md),
          ...features.map((feature) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildMainFeatureCard(feature),
              )),
        ],
      ),
    );
  }

  Widget _buildMainFeatureCard(_MainFeature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [feature.primaryColor, feature.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          onTap: feature.onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    feature.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            feature.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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

  Widget _buildHealthTipsSection() {
    return Container(
      margin: const EdgeInsets.all(theme.AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips Kesehatan Hari Ini',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: theme.AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selalu Siap Siaga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pastikan kotak P3K di rumah selalu lengkap dan mudah dijangkau saat darurat.',
                        style: TextStyle(
                          fontSize: 14,
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

  Widget _buildArticlesSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        theme.AppSpacing.lg,
        theme.AppSpacing.lg,
        theme.AppSpacing.lg,
        theme.AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Artikel Kesehatan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              try {
                Navigator.pushNamed(context, '/articles');
              } catch (e) {
                print('Navigation error: $e');
              }
            },
            child: const Text('Lihat Semua'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSectionBody() {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading || state is ArticleInitial) {
          return _buildArticlePlaceholderList();
        } else if (state is ArticleLoaded) {
          return _buildArticleList(state.articles);
        } else if (state is ArticleError) {
          return _buildErrorMessage();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildArticleList(List<Article> articles) {
    final displayArticles =
        articles.length > 3 ? articles.take(3).toList() : articles;

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayArticles.length,
        itemBuilder: (context, index) =>
            _buildArticleCard(displayArticles[index]),
        separatorBuilder: (context, index) =>
            const SizedBox(width: theme.AppSpacing.md),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Container(
      width: 280,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
          return Container(
            color: Colors.grey.shade100,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _buildArticlePlaceholderList() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildArticleCardPlaceholder(),
        separatorBuilder: (context, index) =>
            const SizedBox(width: theme.AppSpacing.md),
      ),
    );
  }

  Widget _buildArticleCardPlaceholder() {
    return Container(
      width: 280,
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
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

  Widget _buildErrorMessage() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(theme.AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Center(
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
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka link: $url'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('URL launch error: $e');
    }
  }
}