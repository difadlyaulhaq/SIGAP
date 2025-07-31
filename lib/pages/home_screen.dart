import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// Sesuaikan path impor tema Anda
import '../theme/theme.dart';

// Impor halaman lain
import 'wound_detection_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'articles_screen.dart';

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
      // Menggunakan IndexedStack untuk menjaga state setiap halaman
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

// Konten Halaman Utama sekarang menjadi StatefulWidget untuk menjaga state
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

// Gunakan AutomaticKeepAliveClientMixin untuk mencegah state hilang
class _HomePageContentState extends State<HomePageContent> with AutomaticKeepAliveClientMixin {

  // Override wantKeepAlive dan return true agar state tidak di-dispose
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Panggil super.build(context) sesuai requirement mixin
    super.build(context);

    final List<_Feature> features = _getFeatures(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header dinamis baru
        _buildModernHeader(context, 'Pengguna'),
        _buildFeaturesSection(features),
        _buildArticlesSection(),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  // WIDGET BUILDER UNTUK HEADER DINAMIS SESUAI WAKTU
  Widget _buildModernHeader(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    // Logika untuk menentukan sapaan berdasarkan waktu
    if (hour < 12) {
      greeting = 'Selamat Pagi'; // Ganti dengan S.of(context).good_morning jika menggunakan flutter_localizations
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Selamat Siang'; // Ganti dengan S.of(context).good_afternoon
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Selamat Malam'; // Ganti dengan S.of(context).good_evening
      greetingIcon = Icons.nights_stay_rounded;
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: primaryGradient,
          ),
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
                      Text(
                        greeting,
                        style: bodyMediumTextStyle.copyWith(
                          color: whiteColor.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: headingMediumTextStyle.copyWith(
                          color: whiteColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tetap tenang, kami siap membantu Anda.', // Ganti dengan S.of(context).motivational_message
              style: bodyMediumTextStyle.copyWith(
                color: whiteColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Kode lainnya (getFeatures, buildFeatureCard, buildArticleCard) tetap sama,
  // namun dipisahkan menjadi sliver terpisah untuk kejelasan.

  Widget _buildFeaturesSection(List<_Feature> features) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text('Fitur Cepat', style: headingSmallTextStyle),
            ),
          ),
          SliverGrid(
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
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
     return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverMainAxisGroup(
        slivers: [
           SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
              child: Text('Artikel Terbaru', style: headingSmallTextStyle),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildArticleCard(context, index),
              childCount: 5, // Tampilkan 5 artikel contoh
            ),
          ),
        ],
      ),
    );
  }

  // (Sisa fungsi seperti _getFeatures, _buildFeatureCard, _buildArticleCard tidak berubah)
  List<_Feature> _getFeatures(BuildContext context) {
    return [
      _Feature(
        icon: Icons.camera_alt,
        title: 'Deteksi Luka',
        subtitle: 'Analisis luka via kamera',
        gradient: [const Color(0xFF4C6EF5), const Color(0xFF2E5B97)], // Biru
        onTap: () => Navigator.pushNamed(context, '/detect'),
      ),
      _Feature(
        icon: Icons.chat_bubble,
        title: 'Chatbot',
        subtitle: 'Tanya jawab P3K',
        gradient: [const Color(0xFF34D399), const Color(0xFF10B981)], // Hijau
        onTap: () => Navigator.pushNamed(context, '/chatbot'),
      ),
      _Feature(
        icon: Icons.local_hospital,
        title: 'Darurat',
        subtitle: 'Panggil bantuan cepat',
        gradient: [const Color(0xFFF78CA0), const Color(0xFFF9748F)], // Merah muda
        onTap: () { /* Logika panggilan darurat */ },
      ),
      _Feature(
        icon: Icons.article,
        title: 'Semua Artikel',
        subtitle: 'Lihat info kesehatan',
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Oranye
        onTap: () => Navigator.pushNamed(context, '/articles'),
      ),
    ];
  }

  Widget _buildFeatureCard(BuildContext context, _Feature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: feature.gradient,
        ),
        borderRadius: xLargeRadius,
        boxShadow: [
          BoxShadow(
            color: feature.gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(feature.icon, color: whiteColor, size: 36),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  feature.title,
                  style: buttonLargeTextStyle.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  feature.subtitle,
                  style: bodySmallTextStyle.copyWith(color: whiteColor.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: mediumRadius),
      color: cardColor,
      child: InkWell(
        borderRadius: mediumRadius,
        onTap: () { /* Navigasi ke detail artikel */ },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: smallRadius,
                child: Container(
                  width: 80,
                  height: 80,
                  color: backgroundLight,
                  child: Icon(Icons.image, color: textTertiaryColor.withOpacity(0.5)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips Pertolongan Pertama untuk Luka Bakar',
                      style: modernBlackTextStyle.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Kategori: P3K • 5 menit baca',
                      style: bodySmallTextStyle,
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
}