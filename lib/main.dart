import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:rescuein/bloc/auth/auth_bloc.dart';
import 'package:rescuein/bloc/auth/auth_repository.dart';
import 'package:rescuein/bloc/load_profile/load_profile_bloc.dart';
import 'package:rescuein/pages/articles_screen.dart';
import 'package:rescuein/pages/chatbot_screen.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/learning_page.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/pages/profile_screen.dart';
import 'package:rescuein/pages/signup_screen.dart';
import 'package:rescuein/pages/splash_screen.dart';
import 'package:rescuein/pages/wound_detection_screen.dart';
import 'package:rescuein/theme/theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // Pastikan semua binding siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Muat environment variables dari file .env
  await dotenv.load(fileName: ".env");

  // Atur Access Token untuk Mapbox
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan MultiProvider untuk mendaftarkan semua Repository dan BLoC
    // di satu tempat agar lebih rapi.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        // Tambahkan repository lain di sini jika ada
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          // MENAMBAHKAN PROFILE BLOC
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          // Tambahkan BLoC lain di sini jika ada
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SIGAP',
          theme: ThemeData(
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

          // Halaman awal tetap SplashScreen, karena di sanalah logika
          // pengecekan status login seharusnya berada.
          home: const SplashScreen(),

          // Daftarkan semua rute untuk navigasi dengan nama
          routes: {
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