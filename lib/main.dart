import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hourlink/core/theme/appTheme.dart';
import 'package:hourlink/features/auth/presentation/pages/how_to_use_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/login_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/main_scaffold.dart';
import 'package:hourlink/firebase_options.dart';
import 'package:hourlink/features/auth/data/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // 👈 from firebase_options.dart
  );

  // Restore saved dark mode preference before the app renders anything.
  await AppTheme.load();

  // Cache la navbar du bas — immersiveSticky permet à la navbar de
  // réapparaître temporairement lors d'un swipe puis de se recacher
  // automatiquement, contrairement à SystemUiMode.manual qui la
  // laissait affichée en permanence une fois révélée.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // ← garde la status bar, cache la navbar
  );

  runApp(const Hourlink());
}

class Hourlink extends StatefulWidget {
  const Hourlink({super.key});

  @override
  State<Hourlink> createState() => _HourlinkState();
}

class _HourlinkState extends State<Hourlink> with WidgetsBindingObserver {
  // Forces the splash to stay visible for a minimum duration, regardless
  // of how fast Firebase resolves the cached auth state (which can be
  // near-instant on a real device and otherwise never get a chance to render).
  bool _minSplashElapsed = false;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _minSplashElapsed = true);
    });
    if (FirebaseAuth.instance.currentUser != null) {
      _authService.googleSignIn.signInSilently();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-applies immersive mode whenever the app comes back to the
  // foreground — some OEM Android skins (e.g. Realme UI) don't reliably
  // keep the sticky immersive state across resume events on their own.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'HourLink',
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final stillWaitingOnAuth =
                  snapshot.connectionState == ConnectionState.waiting;

              // Keep showing a blank branded background until BOTH the
              // minimum duration has passed AND Firebase has resolved the
              // auth state — matches the native launch_background.xml color
              // so there's no visible seam when Flutter's first frame draws.
              if (stillWaitingOnAuth || !_minSplashElapsed) {
                return Scaffold(backgroundColor: AppColors.background);
              }

              final user = snapshot.data;
              if (user == null) {
                return LoginScreen(); // not logged in
              }

              // Single source of truth for routing post-sign-in: this
              // StreamBuilder fires automatically on every auth state
              // change, so LoginScreen no longer needs to navigate itself.
              return _isNewUser(user) ? HowToUseScreen() : MainScaffold();
            },
          ),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }

  /// A brand-new Firebase account has creationTime == lastSignInTime
  /// (small tolerance for clock/network skew). Returning users keep
  /// the same creationTime while lastSignInTime moves forward.
  bool _isNewUser(User user) {
    final created = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;
    if (created == null || lastSignIn == null) return false;
    return lastSignIn.difference(created).inSeconds.abs() < 5;
  }
}
