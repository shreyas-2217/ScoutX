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
import 'providers/fab_visibility_provider.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shared/clip_player_screen.dart';
import 'screens/shared/setup_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shell/role_shell.dart';
import 'services/auth_service.dart';
import 'services/database.dart';
import 'design_system.dart' show DSColors;

bool _firebaseReady = false;

String? _clipIdFromLaunchUri() {
  final uri = Uri.base;
  final fragMatch = RegExp(r'^/?clip/([^/?#]+)').firstMatch(uri.fragment);
  if (fragMatch != null) return fragMatch.group(1);
  final segments = uri.pathSegments;
  final i = segments.indexOf('clip');
  if (i != -1 && i + 1 < segments.length) return segments[i + 1];
  return null;
}

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
        ChangeNotifierProvider(create: (_) => FabVisibilityProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ScoutX',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            scrollBehavior: SmoothScrollBehavior(),
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
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _openDeepLinkedClip() async {
    final clipId = _clipIdFromLaunchUri();
    if (clipId == null || clipId.isEmpty) return;
    try {
      final clip = await context.read<Database>().getClip(clipId);
      if (!mounted || clip == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClipPlayerScreen(
            videoUrl: clip.videoUrl,
            title: clip.title.isEmpty ? null : clip.title,
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    final auth = context.watch<AuthProvider>();
    if (!_firebaseReady) {
      // Firebase failed to initialize — show the diagnostic setup screen
      // instead of LoginScreen, where every auth call would fail opaquely.
      child = const SetupScreen();
    } else {
      if (auth.loadingProfile) {
        child = Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: DSColors.onSurface),
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
          if (!_deepLinkHandled) {
            _deepLinkHandled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openDeepLinkedClip();
            });
          }
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(auth.isLoggedIn ? 'authed' : 'guest'),
        child: child,
      ),
    );
  }
}