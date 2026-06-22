import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hourlink/features/auth/presentation/pages/login_screen.dart';
import 'package:hourlink/features/auth/presentation/pages/splash_screen.dart';

void main() {
  // Cache uniquement la navbar du bas
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top], // ← garde la status bar, cache la navbar
  );
  runApp(const Hourlink());
}

class Hourlink extends StatelessWidget {
  const Hourlink({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HourLink',
      debugShowCheckedModeBanner: false,
      //initialRoute: '/',
      //routes: {'/': (_) => const LoginScreen()},
      home: const SplashScreen(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
