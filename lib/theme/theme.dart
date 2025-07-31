import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MODERN EDUCATIONAL COLOR PALETTE ---
// Inspirasi: Kombinasi yang menenangkan namun energik untuk lingkungan pendidikan

// Warna Primer: Teal yang menenangkan dan profesional.
Color primaryColor = const Color(0xFF00796B); // Teal - melambangkan kesehatan, ketenangan, dan kepercayaan.
// Warna Aksen: Hijau muda yang segar untuk interaksi dan highlight positif.
Color accentColor = const Color(0xFF81C784); // Light Green - untuk tombol aksi, sukses, dan elemen interaktif.
// Warna Sekunder: Biru langit yang lembut dan bersih.
Color secondaryColor = const Color(0xFFB3E5FC); // Light Cyan - untuk latar belakang info atau highlight sekunder.

// Warna Netral (Sudah bagus, dipertahankan dengan sedikit penyesuaian)
Color surfaceColor = const Color(0xFFFAFBFC); // Off-white yang sangat lembut
Color backgroundLight = const Color(0xFFF5F7FA); // Light gray-blue
Color cardColor = const Color(0xFFFFFFFF); // Pure white untuk kartu
Color borderColor = const Color(0xFFE2E8F0); // Light blue-gray untuk border

// Warna Teks (Sudah bagus, dipertahankan)
Color textPrimaryColor = const Color(0xFF1A202C); // Dark slate
Color textSecondaryColor = const Color(0xFF4A5568); // Medium slate
Color textTertiaryColor = const Color(0xFF718096); // Light slate

// Warna Status yang Disesuaikan
Color whiteColor = const Color(0xFFFFFFFF);
Color successColor = const Color(0xFF388E3C); // Green yang lebih dalam untuk status sukses
Color warningColor = const Color(0xFFFFB74D); // Warm Orange untuk peringatan
Color errorColor = const Color(0xFFE57373); // Merah yang lebih lembut untuk error
Color infoColor = const Color(0xFF29B6F6); // Light Blue untuk info

// Gradients baru yang sesuai dengan tema
List<Color> primaryGradient = [
  const Color(0xFF4DB6AC), // Teal 300
  const Color(0xFF00796B), // Teal 700
];

List<Color> accentGradient = [
  const Color(0xFFA5D6A7), // Green 200
  const Color(0xFF81C784), // Green 300
];

// --- TYPOGRAPHY (Menggunakan Inter untuk keterbacaan optimal) ---

TextStyle primaryTextStyle = GoogleFonts.inter(
  color: primaryColor,
  fontWeight: FontWeight.w500,
);

TextStyle modernWhiteTextStyle = GoogleFonts.inter(
  color: whiteColor,
  fontWeight: FontWeight.w500,
);

TextStyle modernBlackTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontWeight: FontWeight.w500,
);

TextStyle accentTextStyle = GoogleFonts.inter(
  color: accentColor,
  fontWeight: FontWeight.w600,
);

TextStyle secondaryTextStyle = GoogleFonts.inter(
  color: secondaryColor,
  fontWeight: FontWeight.w500,
);

TextStyle grayTextStyle = GoogleFonts.inter(
  color: textSecondaryColor,
  fontWeight: FontWeight.w400,
);

// Heading Styles
TextStyle headingXLargeTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 32,
  fontWeight: FontWeight.w800,
  height: 1.2,
);

TextStyle headingLargeTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 28,
  fontWeight: FontWeight.w700,
  height: 1.3,
);

TextStyle headingMediumTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 24,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

TextStyle headingSmallTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

// Body Styles
TextStyle bodyLargeTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.6,
);

TextStyle bodyMediumTextStyle = GoogleFonts.inter(
  color: textPrimaryColor,
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

TextStyle bodySmallTextStyle = GoogleFonts.inter(
  color: textSecondaryColor,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.4,
);

// Button Styles
TextStyle buttonLargeTextStyle = GoogleFonts.inter(
  color: whiteColor,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
);

TextStyle buttonMediumTextStyle = GoogleFonts.inter(
  color: whiteColor,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.25,
);

TextStyle buttonSmallTextStyle = GoogleFonts.inter(
  color: whiteColor,
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.25,
);

// --- SHADOWS ---
BoxShadow lightShadow = BoxShadow(
  color: Colors.black.withOpacity(0.04),
  blurRadius: 8,
  offset: const Offset(0, 2),
);

BoxShadow mediumShadow = BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 16,
  offset: const Offset(0, 4),
);

BoxShadow strongShadow = BoxShadow(
  color: Colors.black.withOpacity(0.12),
  blurRadius: 24,
  offset: const Offset(0, 8),
);

// Card Shadow
BoxShadow cardShadow = BoxShadow(
  color: primaryColor.withOpacity(0.08),
  blurRadius: 20,
  offset: const Offset(0, 4),
);

// --- BORDER RADIUS ---
BorderRadius smallRadius = BorderRadius.circular(8);
BorderRadius mediumRadius = BorderRadius.circular(12);
BorderRadius largeRadius = BorderRadius.circular(16);
BorderRadius xLargeRadius = BorderRadius.circular(20);
BorderRadius xxLargeRadius = BorderRadius.circular(24);

// --- SPACING CONSTANTS ---
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// --- ANIMATION DURATIONS ---
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 800);
}