import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import '../theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
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
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
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
        child: FadeTransition(
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
                        // Profile Header
                        _buildProfileHeader(),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Menu Items
                        _buildMenuSection(),
                        
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
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: largeRadius,
        boxShadow: [cardShadow],
      ),
      child: Column(
        children: [
          // Profile Picture with Status
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
          
          // User Info
          Text(
            'Dr. Ahmad Nugraha',
            style: headingMediumTextStyle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ahmad.nugraha@email.com',
            style: bodyMediumTextStyle.copyWith(
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Status Badge
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
  Widget _buildMenuSection() {
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
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            icon: Icons.medical_information_outlined,
            title: 'Riwayat Medis',
            subtitle: 'Lihat riwayat kesehatan Anda',
            onTap: () {},
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