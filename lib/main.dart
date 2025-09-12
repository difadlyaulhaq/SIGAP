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
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
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
          home: const SplashScreen(),
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