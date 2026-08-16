import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scoutx/theme.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/location_provider.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shared/setup_screen.dart'
    show SetupScreen;
import 'screens/shared/splash_screen.dart';
import 'screens/shell/role_shell.dart';
import 'services/auth_service.dart';
import 'services/database.dart';
import 'design_system.dart'
    show DSColors;

bool _firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    _firebaseReady = true;
  } catch (_) {
    _firebaseReady = false;
  }
  runApp(const ScoutXApp());
}

class ScoutXApp extends StatelessWidget {
  const ScoutXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: AuthService()),
        Provider.value(value: Database()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<Database>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ScoutX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: const HomeGate(),
          );
        },
      ),
    );
  }
}

class HomeGate extends StatefulWidget {
  const HomeGate({super.key});

  @override
  State<HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<HomeGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!_firebaseReady) {
      child = const SetupScreen();
    } else {
      final auth = context.watch<AuthProvider>();
      if (auth.loadingProfile) {
        child = Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: DSColors.volt),
                const SizedBox(height: 16),
                Text(
                  'Loading your profile...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DSColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      } else if (!auth.isLoggedIn) {
        child = const LoginScreen();
      } else {
        final profile = auth.profile;
        if (profile == null) {
          child = const CompleteProfileScreen();
        } else {
          child = RoleShell(profile: profile);
        }
      }
    }

    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          if (mounted) {
            setState(() => _showSplash = false);
          }
        },
      );
    }

    return child;
  }
}