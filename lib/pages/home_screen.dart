import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/pages/hospital_nearby_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart' as theme;
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// FIXED: Class _Feature dipindahkan ke top-level (luar class lain).
// Ini adalah struktur yang benar di Dart.
class _Feature {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: context.read<AuthRepository>(),
      )..add(FetchProfileData()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView();

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  late PageController _pageController;
  int _pageIndex = 0;

  // FIXED: Inisialisasi _pages dipindahkan ke initState
  // agar bisa meneruskan fungsi instance (_onNavigationTap) ke child widget.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    _pages = [
      HomePageContent(onNavigate: _onNavigationTap), // Kirim fungsi ke child
      const HospitalNearbyPage(),
      const ChatbotScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundLight,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/detect'),
        backgroundColor: theme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 65.0,
        color: theme.whiteColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home_filled, index: 0),
            _buildNavItem(icon: Icons.local_hospital_outlined, index: 1),
            const SizedBox(width: 48), // The space for the FAB
            _buildNavItem(icon: Icons.chat_bubble_outline, index: 2),
            _buildNavItem(icon: Icons.person_outline, index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _pageIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? theme.primaryColor : theme.textTertiaryColor,
        size: 30,
      ),
      onPressed: () => _onNavigationTap(index),
    );
  }
}

class HomePageContent extends StatefulWidget {
  // FIXED: Tambahkan parameter onNavigate untuk menerima fungsi dari parent.
  final void Function(int) onNavigate;

  const HomePageContent({super.key, required this.onNavigate});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final List<_Feature> _features;

  @override
  void initState() {
    super.initState();
    // Sekarang _getFeatures bisa di-passing context
    _features = _getFeatures(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String userName = 'Pengguna';
        if (state is ProfileLoaded) {
          userName = state.user.nama.split(' ').first;
        } else if (state is ProfileFailure) {
          userName = 'Tamu';
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernHeader(context, userName),
            _buildFeaturesSection(),
            _buildArticlesSectionHeader(),
            _buildArticlesSectionBody(),
            const SliverToBoxAdapter(
                child: SizedBox(height: theme.AppSpacing.xxl)),
          ],
        );
      },
    );
  }

  Future<void> _showEmergencyCallConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: theme.largeRadius),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.warningColor),
              const SizedBox(width: theme.AppSpacing.sm),
              Text('Konfirmasi', style: theme.headingSmallTextStyle),
            ],
          ),
          content: Text(
            'Anda akan melakukan panggilan ke nomor darurat 112. Lanjutkan?',
            style: theme.bodyMediumTextStyle,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal',
                  style: theme.modernBlackTextStyle
                      .copyWith(color: theme.textSecondaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.errorColor,
                shape: RoundedRectangleBorder(borderRadius: theme.mediumRadius),
              ),
              child: Text('Panggil', style: theme.buttonMediumTextStyle),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _makeEmergencyCall();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat melakukan panggilan.',
                style: theme.bodyMediumTextStyle),
            backgroundColor: theme.errorColor,
          ),
        );
      }
    }
  }

  List<_Feature> _getFeatures(BuildContext context) {
    return [
      _Feature(
        icon: Icons.chat_bubble,
        title: 'Chatbot',
        subtitle: 'Tanya jawab P3K',
        gradient: [const Color(0xFF34D399), const Color(0xFF10B981)],
        onTap: () => Navigator.pushNamed(context, '/chatbot'),
      ),
      _Feature(
        icon: Icons.local_hospital,
        title: 'Darurat',
        subtitle: 'Panggil bantuan cepat',
        gradient: [const Color(0xFFF78CA0), const Color(0xFFF9748F)],
        onTap: () => _showEmergencyCallConfirmation(context),
      ),
      _Feature(
        icon: Icons.article,
        title: 'Semua Artikel',
        subtitle: 'Lihat info kesehatan',
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        onTap: () => Navigator.pushNamed(context, '/articles'),
      ),
      _Feature(
        icon: Icons.map,
        title: 'RS Terdekat',
        subtitle: 'Cari fasilitas medis',
        gradient: [const Color(0xFF4C6EF5), const Color(0xFF2E5B97)],
        // FIXED: Panggil fungsi onNavigate yang didapat dari parent.
        onTap: () => widget.onNavigate(1),
      ),
    ];
  }

  Widget _buildModernHeader(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return SliverAppBar(
      expandedHeight: 180.0,
      backgroundColor: theme.backgroundLight,
      pinned: true,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.all(theme.AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(theme.AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: theme.primaryGradient),
              borderRadius: theme.xxLargeRadius,
              boxShadow: [theme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon, color: theme.whiteColor, size: 28),
                    const SizedBox(width: theme.AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting,
                              style: theme.bodyMediumTextStyle.copyWith(
                                  color: theme.whiteColor.withOpacity(0.9))),
                          Text(userName,
                              style: theme.headingMediumTextStyle
                                  .copyWith(color: theme.whiteColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: theme.AppSpacing.md),
                Text('Tetap tenang, kami siap membantu Anda.',
                    style: theme.bodyMediumTextStyle
                        .copyWith(color: theme.whiteColor.withOpacity(0.9))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: theme.AppSpacing.md,
          mainAxisSpacing: theme.AppSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _FadeInAnimation(
            delay: Duration(milliseconds: 100 * index),
            child: _buildFeatureCard(context, _features[index]),
          ),
          childCount: _features.length,
        ),
      ),
    );
  }

  Widget _buildArticlesSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(theme.AppSpacing.lg,
            theme.AppSpacing.xl, theme.AppSpacing.lg, theme.AppSpacing.md),
        child: Text('Artikel Terbaru', style: theme.headingSmallTextStyle),
      ),
    );
  }

  Widget _buildArticlesSectionBody() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          return _FadeInAnimation(
            delay: Duration(milliseconds: 50 * index),
            child: _buildArticleCard(context, index),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: theme.AppSpacing.md),
        itemCount: 5,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _Feature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: feature.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: theme.xLargeRadius,
        boxShadow: [
          BoxShadow(
              color: feature.gradient.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: theme.xLargeRadius,
          onTap: feature.onTap,
          child: Padding(
            padding: const EdgeInsets.all(theme.AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature.icon, color: theme.whiteColor, size: 36),
                const SizedBox(height: theme.AppSpacing.sm),
                Text(feature.title,
                    style: theme.buttonLargeTextStyle.copyWith(fontSize: 18),
                    textAlign: TextAlign.center),
                const SizedBox(height: theme.AppSpacing.xs),
                Text(feature.subtitle,
                    style: theme.bodySmallTextStyle
                        .copyWith(color: theme.whiteColor.withOpacity(0.8)),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, int index) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: theme.mediumRadius),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: theme.mediumRadius,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(theme.AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: theme.smallRadius,
                  child: Image.network(
                    'https://picsum.photos/seed/${index + 10}/200',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: theme.backgroundLight,
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: theme.primaryColor,
                        )),
                      );
                    },
                  )),
              const SizedBox(width: theme.AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips Pertolongan Pertama untuk Luka Bakar',
                        style: theme.modernBlackTextStyle
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: theme.AppSpacing.sm),
                    Text('Kategori: P3K • 5 menit baca',
                        style: theme.bodySmallTextStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _FadeInAnimation({required this.child, this.delay = Duration.zero});

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: widget.child,
    );
  }
}