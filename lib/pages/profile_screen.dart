import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS BARU ---
import 'package:rescuein/bloc/auth/auth_repository.dart'; // Diperlukan untuk menyediakan repository ke BLoC
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/pages/medical_history_screen.dart'; // Halaman riwayat medis

// --- IMPORTS LAMA ---
import 'login_screen.dart';
import '../theme/theme.dart';

// Bagian 1: Widget utama yang menyediakan BLoC
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        // Mengambil AuthRepository dari context yang lebih tinggi (asumsi sudah disediakan di main.dart atau di atasnya)
        authRepository: context.read<AuthRepository>(),
      )..add(FetchProfileData()), // Langsung memanggil event untuk mengambil data
      child: const ProfileView(), // Widget yang akan menampilkan UI
    );
  }
}

// Bagian 2: Widget View yang berisi UI dan state lokal (animasi, dll.)
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.medium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          title: Text(
            'Konfirmasi Logout',
            style: headingSmallTextStyle,
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: bodyMediumTextStyle.copyWith(color: textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: bodyMediumTextStyle.copyWith(
                  color: textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(borderRadius: smallRadius),
              ),
              child: Text(
                'Logout',
                style: buttonMediumTextStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppDurations.medium,
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        // Menggunakan BlocBuilder untuk merender UI berdasarkan state dari ProfileBloc
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // State ketika data sedang diambil
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // State ketika data berhasil didapatkan
            if (state is ProfileLoaded) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    slivers: [
                      // Custom App Bar
                      _buildSliverAppBar(),
                      
                      // Profile Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Profile Header, kini dengan data dinamis
                              _buildProfileHeader(state),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Menu Items, kini dengan navigasi
                              _buildMenuSection(state),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Logout Button
                              _buildLogoutButton(),
                              
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // State ketika terjadi error
            if (state is ProfileFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Gagal memuat data profil:\n${state.message}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Fallback jika ada state yang tidak terduga
            return const Center(child: Text('Terjadi kesalahan.'));
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.inter(
            color: whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: primaryGradient,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: whiteColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: whiteColor),
          onPressed: () {
            // Navigasi ke halaman settings
          },
        ),
      ],
    );
  }

  // MODIFIKASI: Menerima state ProfileLoaded untuk data dinamis
  Widget _buildProfileHeader(ProfileLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [cardShadow],
      ),
      child: Column(
        children: [
          // Widget Profile Picture (tidak berubah)
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: accentGradient,
                  ),
                  boxShadow: [mediumShadow],
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: whiteColor,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: whiteColor, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: whiteColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // ---- DATA DINAMIS ----
          // Menampilkan nama dari state.user
          Text(
            state.user.nama,
            style: headingMediumTextStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Menampilkan email dari state.user
          Text(
            state.user.email,
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Status Badge (tidak berubah)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: smallRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: successColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Aktif',
                  style: bodySmallTextStyle.copyWith(
                    color: successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIKASI: Menerima state ProfileLoaded untuk navigasi
  Widget _buildMenuSection(ProfileLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [lightShadow],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profil',
            subtitle: 'Ubah informasi pribadi Anda',
            onTap: () {
              // TODO: Implementasi navigasi ke halaman edit profil
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.medical_information_outlined,
            title: 'Riwayat Medis',
            subtitle: 'Lihat riwayat kesehatan Anda',
            onTap: () {
              // --- NAVIGASI KE HALAMAN RIWAYAT MEDIS ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalHistoryScreen(
                    medicalHistory: state.medicalHistory,
                  ),
                ),
              );
            },
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Atur pengingat dan notifikasi',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Keamanan',
            subtitle: 'Password dan keamanan akun',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan & FAQ',
            subtitle: 'Pusat bantuan dan dukungan',
            onTap: () {},
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Informasi aplikasi dan versi',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: smallRadius,
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(title, style: bodyLargeTextStyle),
      subtitle: Text(
        subtitle,
        style: bodySmallTextStyle.copyWith(height: 1.3),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textTertiaryColor,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      color: borderColor,
      indent: AppSpacing.xxl + AppSpacing.md,
      endIndent: AppSpacing.lg,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: mediumRadius,
        border: Border.all(color: errorColor.withOpacity(0.3)),
      ),
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: mediumRadius,
          ),
        ),
        icon: Icon(Icons.logout, color: errorColor),
        label: Text(
          'Logout',
          style: buttonLargeTextStyle.copyWith(color: errorColor),
        ),
      ),
    );
  }
}