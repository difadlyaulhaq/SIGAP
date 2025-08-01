import 'package:flutter/material.dart';
import 'package:rescuein/pages/articles_screen.dart';
import 'package:rescuein/pages/chatbot_screen.dart';
import 'package:rescuein/pages/home_screen.dart';
import 'package:rescuein/pages/login_screen.dart';
import 'package:rescuein/pages/profile_screen.dart';
import 'package:rescuein/pages/signup_screen.dart';
import 'package:rescuein/pages/wound_detection_screen.dart';
     // Buat file ini

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Pertolongan Pertama',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      // 2. Tentukan rute awal aplikasi
      initialRoute: '/login',

      // 3. Daftarkan semua rute (halaman) yang ada di aplikasi Anda
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/detect': (context) => const WoundDetectionScreen(),
        '/articles': (context) => const ArticlesScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}