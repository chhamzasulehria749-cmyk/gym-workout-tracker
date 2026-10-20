import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/workout_service.dart';
import 'theme/app_theme.dart';
import 'database/app_database.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // FIREBASE
  // ==========================================

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ==========================================
  // FORCE LOGIN SCREEN ON APP START
  // ==========================================

  await FirebaseAuth.instance.signOut();

  // ==========================================
  // HIVE
  // ==========================================

  await Hive.initFlutter();

  await Hive.openBox(WorkoutService.boxName);

  await Hive.openBox('settingsBox');

  // ==========================================
  // DRIFT / SQLITE
  // ==========================================

  final database = AppDatabase();

  final databaseService = DatabaseService(database);

  // ==========================================
  // START APP
  // ==========================================

  runApp(GymTrackerApp(databaseService: databaseService));
}

class GymTrackerApp extends StatelessWidget {
  final DatabaseService databaseService;

  const GymTrackerApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(databaseService)..loadData(),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'Gym Tracker',

            theme: AppTheme.lightTheme,

            darkTheme: AppTheme.darkTheme,

            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

// ==========================================
// AUTH GATE
// ==========================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Firebase is checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // User is NOT logged in
        return const LoginScreen();
      },
    );
  }
}
