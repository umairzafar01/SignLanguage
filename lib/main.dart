import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/providers/app_preferences_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/progress_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseEnabled = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    firebaseEnabled = false;
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // System UI is configured per-theme in AppTheme; set a safe default here.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFFFFFFFF),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(SignBridgeApp(firebaseEnabled: firebaseEnabled));
}

class SignBridgeApp extends StatelessWidget {
  final bool firebaseEnabled;
  const SignBridgeApp({super.key, required this.firebaseEnabled});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(firebaseEnabled: firebaseEnabled),
        ),
        ChangeNotifierProvider(
          create: (_) => AppPreferencesProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..initialize(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProgressProvider>(
          create: (_) => UserProgressProvider(),
          update: (_, auth, progress) {
            final provider = progress ?? UserProgressProvider();
            provider.initializeForUser(
                auth.isAuthenticated ? auth.userId : null);
            return provider;
          },
        ),
      ],
      child: Consumer<AppPreferencesProvider>(
        builder: (_, prefs, __) => MaterialApp(
          title: 'SignBridge',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: prefs.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
