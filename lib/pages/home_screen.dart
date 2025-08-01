import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- Impor plugin baru
import '../theme/theme.dart'; // Sesuaikan path impor tema Anda

// Impor halaman lain
import 'wound_detection_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'articles_screen.dart';

// Model internal untuk data kartu fitur (tidak berubah)
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

// HomeScreen dan _HomeScreenState (tidak berubah)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const WoundDetectionScreen(),
    const ChatbotScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 65.0,
        items: const <Widget>[
          Icon(Icons.home_filled, size: 30, color: Colors.white),
          Icon(Icons.camera_alt_outlined, size: 30, color: Colors.white),
          Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
        color: primaryColor,
        buttonBackgroundColor: primaryColor,
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

// Konten Halaman Utama dengan fungsionalitas baru
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
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  // --- FUNGSI BARU UNTUK DIALOG KONFIRMASI PANGGILAN DARURAT ---
  Future<void> _showEmergencyCallConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: warningColor),
              const SizedBox(width: AppSpacing.sm),
              Text('Konfirmasi', style: headingSmallTextStyle),
            ],
          ),
          content: Text(
            'Anda akan melakukan panggilan ke nomor darurat 112. Lanjutkan?',
            style: bodyMediumTextStyle,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: modernBlackTextStyle.copyWith(color: textSecondaryColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor, // Gunakan warna error dari tema
                shape: RoundedRectangleBorder(borderRadius: mediumRadius),
              ),
              child: Text('Panggil', style: buttonMediumTextStyle),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                _makeEmergencyCall();
              },
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI BARU UNTUK MELAKUKAN PANGGILAN ---
  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat melakukan panggilan.', style: bodyMediumTextStyle), backgroundColor: errorColor),
      );
    }
  }

  // --- REWRITE: Fungsi _getFeatures sekarang memanggil dialog ---
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
        onTap: () => _showEmergencyCallConfirmation(context), // <-- DIUBAH DI SINI
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

  // --- Widget Builders lainnya tidak ada perubahan signifikan ---
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
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: primaryGradient),
          borderRadius: xxLargeRadius,
          boxShadow: [cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(greetingIcon, color: whiteColor, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: bodyMediumTextStyle.copyWith(color: whiteColor.withOpacity(0.9))),
                      Text(userName, style: headingMediumTextStyle.copyWith(color: whiteColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Tetap tenang, kami siap membantu Anda.', style: bodyMediumTextStyle.copyWith(color: whiteColor.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = _getFeatures(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text('Artikel Terbaru', style: headingSmallTextStyle);
          }
          return _buildArticleCard(context, index - 1);
        },
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemCount: 6, // 1 untuk judul + 5 untuk artikel
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _Feature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: feature.gradient),
        borderRadius: xLargeRadius,
        boxShadow: [BoxShadow(color: feature.gradient.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: xLargeRadius,
          onTap: feature.onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(feature.icon, color: whiteColor, size: 36),
                const SizedBox(height: AppSpacing.sm),
                Text(feature.title, style: buttonLargeTextStyle.copyWith(fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xs),
                Text(feature.subtitle, style: bodySmallTextStyle.copyWith(color: whiteColor.withOpacity(0.8)), textAlign: TextAlign.center),
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
      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      color: cardColor,
      child: InkWell(
        borderRadius: mediumRadius,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: smallRadius,
                child: Container(width: 80, height: 80, color: backgroundLight, child: Icon(Icons.image, color: textTertiaryColor.withOpacity(0.5))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tips Pertolongan Pertama untuk Luka Bakar', style: modernBlackTextStyle.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Kategori: P3K • 5 menit baca', style: bodySmallTextStyle),
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