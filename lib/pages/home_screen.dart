import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:rescuein/pages/hospital_nearby_screen.dart';
import 'package:url_launcher/url_launcher.dart';
// Menggunakan awalan 'theme' untuk impor tema untuk menghindari konflik nama
import '../theme/theme.dart' as theme; 

// Impor halaman lain
import 'chatbot_screen.dart';
import 'profile_screen.dart';

// Model internal untuk data kartu fitur
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

// HomeScreen dan _HomeScreenState
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const HospitalNearbyPage(),
    const ChatbotScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.backgroundLight,
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 65.0,
        items: const <Widget>[
          Icon(Icons.home_filled, size: 30, color: Colors.white),
          Icon(Icons.local_hospital_outlined, size: 30, color: Colors.white),
          Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
        // PERBAIKAN: Menggunakan variabel dari tema dengan awalan
        color: theme.primaryColor, 
        buttonBackgroundColor: theme.primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}

// Konten Halaman Utama
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildModernHeader(context, 'Pengguna'),
        _buildFeaturesSection(),
        _buildArticlesSection(),
        const SliverToBoxAdapter(child: SizedBox(height: theme.AppSpacing.xxl)),
      ],
    );
  }

  // Dialog konfirmasi panggilan darurat
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
              child: Text('Batal', style: theme.modernBlackTextStyle.copyWith(color: theme.textSecondaryColor)),
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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _makeEmergencyCall();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk melakukan panggilan
  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat melakukan panggilan.', style: theme.bodyMediumTextStyle), backgroundColor: theme.errorColor),
        );
      }
    }
  }

  // Fungsi untuk mendapatkan daftar fitur
  List<_Feature> _getFeatures(BuildContext context) {
    return [
      _Feature(
        icon: Icons.camera_alt,
        title: 'Deteksi Luka',
        subtitle: 'Analisis luka via kamera',
        gradient: [const Color(0xFF4C6EF5), const Color(0xFF2E5B97)],
        onTap: () => Navigator.pushNamed(context, '/detect'),
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
    ];
  }

  // Widget builder lainnya
  Widget _buildModernHeader(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(theme.AppSpacing.lg),
        padding: const EdgeInsets.all(theme.AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: theme.primaryGradient),
          borderRadius: theme.xxLargeRadius,
          boxShadow: [theme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(greetingIcon, color: theme.whiteColor, size: 28),
                const SizedBox(width: theme.AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: theme.bodyMediumTextStyle.copyWith(color: theme.whiteColor.withOpacity(0.9))),
                      Text(userName, style: theme.headingMediumTextStyle.copyWith(color: theme.whiteColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: theme.AppSpacing.md),
            Text('Tetap tenang, kami siap membantu Anda.', style: theme.bodyMediumTextStyle.copyWith(color: theme.whiteColor.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = _getFeatures(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: theme.AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: theme.AppSpacing.md,
          mainAxisSpacing: theme.AppSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildFeatureCard(context, features[index]),
          childCount: features.length,
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(theme.AppSpacing.lg, theme.AppSpacing.xl, theme.AppSpacing.lg, 0),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text('Artikel Terbaru', style: theme.headingSmallTextStyle);
          }
          return _buildArticleCard(context, index - 1);
        },
        separatorBuilder: (context, index) => const SizedBox(height: theme.AppSpacing.md),
        itemCount: 6,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _Feature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: feature.gradient),
        borderRadius: theme.xLargeRadius,
        boxShadow: [BoxShadow(color: feature.gradient.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
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
                Text(feature.title, style: theme.buttonLargeTextStyle.copyWith(fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: theme.AppSpacing.xs),
                Text(feature.subtitle, style: theme.bodySmallTextStyle.copyWith(color: theme.whiteColor.withOpacity(0.8)), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, int index) {
    return Card(
      elevation: 0,
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
                child: Container(width: 80, height: 80, color: theme.backgroundLight, child: Icon(Icons.image, color: theme.textTertiaryColor.withOpacity(0.5))),
              ),
              const SizedBox(width: theme.AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips Pertolongan Pertama untuk Luka Bakar', style: theme.modernBlackTextStyle.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: theme.AppSpacing.sm),
                    Text('Kategori: P3K • 5 menit baca', style: theme.bodySmallTextStyle),
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