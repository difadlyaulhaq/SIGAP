import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/bloc/load_profile/load_profile_event.dart';
import 'package:rescuein/bloc/load_profile/load_profile_state.dart';
import 'package:rescuein/pages/medical_history_screen.dart';
import 'login_screen.dart';
import '../theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: context.read<AuthRepository>(),
      )..add(FetchProfileData()),
      child: const ProfileView(),
    );
  }
}

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? screenWidth * 0.3 : 40.0,
            vertical: 24.0,
          ),
          title: Text(
            'Konfirmasi Logout',
            style: headingSmallTextStyle.copyWith(
              fontSize: isLargeScreen ? 22 : 18,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: bodyMediumTextStyle.copyWith(
                  color: textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: isLargeScreen ? 16 : 14,
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
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 24 : 16,
                  vertical: isLargeScreen ? 16 : 12,
                ),
              ),
              child: Text(
                'Logout',
                style: buttonMediumTextStyle.copyWith(
                  fontSize: isLargeScreen ? 16 : 14,
                ),
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final bool isLargeScreen = screenWidth > 600;

    final double horizontalPadding = screenWidth * 0.05;
    final double verticalPadding = isLargeScreen ? 32.0 : 20.0;
    final double spacing = isLargeScreen ? 28.0 : 24.0;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildAppBar(isLargeScreen),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      children: [
                        _buildProfileHeader(state, screenWidth, isLargeScreen),
                        SizedBox(height: spacing),
                        _buildMenuSection(state, isLargeScreen),
                        SizedBox(height: spacing),
                        _buildLogoutButton(isLargeScreen),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is ProfileFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Text(
                    'Gagal memuat data profil:\n${state.message}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return const Center(child: Text('Terjadi kesalahan.'));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLargeScreen) {
    return AppBar(
      title: Text(
        'Profil Saya',
        style: GoogleFonts.inter(
          color: whiteColor,
          fontSize: isLargeScreen ? 24 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: primaryGradient,
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
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader(ProfileLoaded state, double screenWidth, bool isLargeScreen) {
    final double avatarSize = screenWidth * (isLargeScreen ? 0.20 : 0.25);
    final double cameraIconSize = avatarSize * 0.32;
    final double cameraIconContainerSize = avatarSize * 0.16;

    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 32.0 : 20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [cardShadow],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
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
                  size: avatarSize * 0.5,
                  color: whiteColor,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: cameraIconSize,
                  height: cameraIconSize,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: whiteColor, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: cameraIconContainerSize,
                    color: whiteColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? AppSpacing.lg : AppSpacing.md),
          Text(
            state.user.nama,
            style: headingMediumTextStyle.copyWith(
              fontSize: isLargeScreen ? 28 : 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            state.user.email,
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
          SizedBox(height: isLargeScreen ? AppSpacing.md : AppSpacing.sm),
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

  Widget _buildMenuSection(ProfileLoaded state, bool isLargeScreen) {
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
            onTap: () {},
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuDivider(isLargeScreen),
          _buildMenuItem(
            icon: Icons.medical_information_outlined,
            title: 'Riwayat Medis',
            subtitle: 'Lihat riwayat kesehatan Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalHistoryScreen(
                    medicalHistory: state.medicalHistory,
                  ),
                ),
              );
            },
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuDivider(isLargeScreen),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Atur pengingat dan notifikasi',
            onTap: () {},
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuDivider(isLargeScreen),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Keamanan',
            subtitle: 'Password dan keamanan akun',
            onTap: () {},
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuDivider(isLargeScreen),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan & FAQ',
            subtitle: 'Pusat bantuan dan dukungan',
            onTap: () {},
            isLargeScreen: isLargeScreen,
          ),
          _buildMenuDivider(isLargeScreen),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Informasi aplikasi dan versi',
            onTap: () {},
            isLargeScreen: isLargeScreen,
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
    required bool isLargeScreen,
  }) {
    final double iconContainerSize = isLargeScreen ? 50 : 44;
    final double iconSize = isLargeScreen ? 26 : 22;

    return ListTile(
      leading: Container(
        width: iconContainerSize,
        height: iconContainerSize,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: smallRadius,
        ),
        child: Icon(icon, color: primaryColor, size: iconSize),
      ),
      title: Text(
        title,
        style: bodyLargeTextStyle.copyWith(
          fontSize: isLargeScreen ? 18 : 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: bodySmallTextStyle.copyWith(
          height: 1.3,
          fontSize: isLargeScreen ? 14 : 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textTertiaryColor,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : AppSpacing.lg,
        vertical: isLargeScreen ? 12 : AppSpacing.sm,
      ),
    );
  }

  Widget _buildMenuDivider(bool isLargeScreen) {
    final double iconContainerSize = isLargeScreen ? 50 : 44;
    final double horizontalPadding = isLargeScreen ? 24 : AppSpacing.lg;
    
    return Divider(
      height: 1,
      color: borderColor,
      indent: iconContainerSize + horizontalPadding + 12,
      endIndent: horizontalPadding,
    );
  }

  Widget _buildLogoutButton(bool isLargeScreen) {
    return Container(
      width: double.infinity,
      height: isLargeScreen ? 64 : 56,
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
        icon: Icon(Icons.logout, color: errorColor, size: isLargeScreen ? 28 : 24),
        label: Text(
          'Logout',
          style: buttonLargeTextStyle.copyWith(
            color: errorColor,
            fontSize: isLargeScreen ? 18 : 16,
          ),
        ),
      ),
    );
  }
}