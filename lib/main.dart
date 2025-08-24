import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/pages/articles_screen.dart';
import 'package:rescuein/pages/chatbot_screen.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/learning_page.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/pages/profile_screen.dart';
import 'package:rescuein/pages/signup_screen.dart';
import 'package:rescuein/pages/splash_screen.dart'; // Pastikan import splash screen
import 'package:rescuein/pages/wound_detection_screen.dart';
import 'package:rescuein/theme/theme.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // Pastikan semua binding siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan AuthRepository dan AuthBloc ke seluruh widget tree aplikasi
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        )..add(
            AuthCheckRequested(),
          ), // Memeriksa status login saat aplikasi dimulai
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SIGAP',
          theme: ThemeData(
            // Menggunakan tema dari file theme.dart
            primaryColor: primaryColor,
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
            scaffoldBackgroundColor: backgroundLight,
            useMaterial3: true,
            textTheme: TextTheme(
              headlineLarge: headingLargeTextStyle,
              headlineMedium: headingMediumTextStyle,
              bodyLarge: bodyLargeTextStyle,
              bodyMedium: bodyMediumTextStyle,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: cardColor,
              foregroundColor: textPrimaryColor,
              elevation: 0,
            ),
          ),

          // DIUBAH: Halaman awal sekarang adalah SplashScreen, yang akan menangani logika navigasi.
          home: const SplashScreen(),

          // Daftarkan semua rute untuk navigasi dengan nama
          routes: {
            // Rute '/splash' bisa dihapus jika tidak digunakan di tempat lain
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/detect': (context) => const WoundDetectionScreen(),
            '/articles': (context) => const ArticlesScreen(),
            '/chatbot': (context) => const ChatbotScreen(),
            '/learning': (context) => const LearningHomeScreen(),
          },
        ),
      ),
    );
  }
}
