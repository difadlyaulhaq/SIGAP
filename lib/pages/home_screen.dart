import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/article/article_bloc.dart';
import 'package:rescuein/bloc/article/article_event.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/article/article_state.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/models/article_model.dart';
import 'package:rescuein/pages/hospital_nearby_screen.dart';
import 'package:rescuein/services/news_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart' as theme;
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// Model untuk data fitur (tidak diubah)
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

// Widget utama (tidak diubah)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileBloc(
            authRepository: context.read<AuthRepository>(),
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

// View utama dengan PageView dan BottomAppBar (tidak ada perubahan signifikan)
class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView();

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  late PageController _pageController;
  int _pageIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
    _pages = [
      // PERBAIKAN: HomePageContent tidak lagi memerlukan onNavigate
      const HomePageContent(),
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
            const SizedBox(width: 48),
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

// --- KONTEN HALAMAN UTAMA (REWRITE DENGAN LISTVIEW) ---
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with AutomaticKeepAliveClientMixin {
  // PERBAIKAN: Mixin untuk mengatasi "tombstoned"
  @override
  bool get wantKeepAlive => true;

  // State lokal untuk daftar fitur, diinisialisasi sekali di initState
  late final List<_Feature> _features;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Panggil _getFeatures di sini agar tidak dipanggil berulang di build
    _features = _getFeatures(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Wajib dipanggil untuk AutomaticKeepAliveClientMixin

    // PERBAIKAN: Menggunakan ListView untuk layout yang lebih stabil dan bisa di-scroll
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: theme.AppSpacing.xxl),
      children: [
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            String userName = 'Pengguna';
            if (state is ProfileLoaded) {
              userName = state.user.nama.split(' ').first;
            }
            return _buildModernHeader(context, userName);
          },
        ),
        const SizedBox(height: theme.AppSpacing.xl),
        _buildFeaturesSection(),
        _buildArticlesSectionHeader(),
        _buildArticlesSectionBody(),
      ],
    );
  }

  // --- Widget Builder ---
  // Masing-masing widget builder kini menjadi widget biasa, bukan sliver.

  List<_Feature> _getFeatures(BuildContext context) {
    return [
      _Feature(
        icon:Icons.school_outlined,
        title: 'Belajar Interaktif',
        subtitle: 'Pelajari P3K dengan cara menyenangkan',
        gradient: [const Color(0xFF4C6EF5), const Color(0xFF2E5B97)],
        onTap: () => Navigator.pushNamed(context, '/learning'),
      ),
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
        // PERBAIKAN: Cara memanggil navigasi diubah agar lebih aman
        onTap: () =>
            context.findAncestorStateOfType<_HomeScreenViewState>()?._onNavigationTap(1),
      ),
    ];
  }

  Widget _buildModernHeader(BuildContext context, String userName) {
    // ... (Isi fungsi ini sama seperti kode Anda)
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

    return Padding(
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
    );
  }

  Widget _buildFeaturesSection() {
    // PERBAIKAN: Menggunakan GridView.count di dalam Padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(), // Non-aktifkan scroll internal
        shrinkWrap: true, // Membuat GridView hanya memakan ruang seperlunya
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: theme.AppSpacing.md,
        mainAxisSpacing: theme.AppSpacing.md,
        children: _features.map((feature) => _buildFeatureCard(context, feature)).toList(),
      ),
    );
  }

  Widget _buildArticlesSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(theme.AppSpacing.lg,
          theme.AppSpacing.xl, theme.AppSpacing.lg, theme.AppSpacing.md),
      child: Text('Artikel Terbaru', style: theme.headingSmallTextStyle),
    );
  }

  Widget _buildArticlesSectionBody() {
    // PERBAIKAN: Menggunakan ListView.separated di dalam BlocBuilder
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading || state is ArticleInitial) {
          return _buildArticlePlaceholderList();
        } else if (state is ArticleLoaded) {
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
            itemBuilder: (context, index) {
              final article = state.articles[index];
              return _buildArticleCard(context, article);
            },
            separatorBuilder: (context, index) =>
                const SizedBox(height: theme.AppSpacing.md),
            // Batasi jumlah artikel di homepage agar tidak terlalu panjang
            itemCount: state.articles.length > 5 ? 5 : state.articles.length,
          );
        } else if (state is ArticleError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat artikel.\nCoba lagi nanti.',
                textAlign: TextAlign.center,
                style: theme.bodyMediumTextStyle
                    .copyWith(color: theme.textSecondaryColor),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // --- Widget-widget lainnya (tidak berubah signifikan) ---

  Widget _buildFeatureCard(BuildContext context, _Feature feature) {
    // ... (Isi fungsi ini sama seperti kode Anda)
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
  
  Widget _buildArticleCard(BuildContext context, Article article) {
    // Tidak ada perubahan di sini, ClipRRect aman digunakan dalam layout yang stabil
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: theme.mediumRadius),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: theme.mediumRadius,
        onTap: () => _launchURL(article.url),
        child: Padding(
          padding: const EdgeInsets.all(theme.AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: theme.smallRadius,
                child: article.urlToImage != null
                    ? Image.network(
                        article.urlToImage!,
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
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          width: 80,
                          height: 80,
                          color: theme.backgroundLight,
                          child: Icon(Icons.broken_image,
                              color: theme.textTertiaryColor),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: theme.backgroundLight,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: theme.textTertiaryColor),
                      ),
              ),
              const SizedBox(width: theme.AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.modernBlackTextStyle
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: theme.AppSpacing.sm),
                    Text(
                      article.sourceName,
                      style: theme.bodySmallTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlePlaceholderList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      itemCount: 3,
      itemBuilder: (context, index) => _buildArticleCardPlaceholder(),
      separatorBuilder: (context, index) =>
          const SizedBox(height: theme.AppSpacing.md),
    );
  }
  
  Widget _buildArticleCardPlaceholder() {
    // ... (Isi fungsi ini sama seperti kode Anda)
        return Container(
      padding: const EdgeInsets.all(theme.AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: theme.mediumRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: theme.smallRadius,
            ),
          ),
          const SizedBox(width: theme.AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 200,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: 100,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Fungsi Helper (tidak diubah) ---
  Future<void> _showEmergencyCallConfirmation(BuildContext context) async {
    // ... (Isi fungsi ini sama seperti kode Anda)
    if (!mounted) return;
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
                shape:
                    RoundedRectangleBorder(borderRadius: theme.mediumRadius),
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
    // ... (Isi fungsi ini sama seperti kode Anda)
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

  Future<void> _launchURL(String url) async {
    // ... (Isi fungsi ini sama seperti kode Anda)
        final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $url')),
        );
      }
    }
  }
}