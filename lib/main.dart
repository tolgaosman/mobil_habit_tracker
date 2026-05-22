import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/habit_provider.dart';
import 'core/providers/routine_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'data/models/habit_model.dart';
import 'data/models/user_model.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitCompletionAdapter());
  Hive.registerAdapter(UserModelAdapter());
  
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<String>('auth_session');

  // Initialize Notifications
  await NotificationService.instance.initialize();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HabitProvider>(
          create: (_) => HabitProvider(),
          update: (_, auth, habitProvider) =>
              habitProvider!..updateUser(auth.currentUser),
        ),
        ChangeNotifierProxyProvider<AuthProvider, RoutineProvider>(
          create: (_) => RoutineProvider(),
          update: (_, auth, routineProvider) =>
              routineProvider!..updateUser(auth.currentUser),
        ),
      ],
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Habits+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
