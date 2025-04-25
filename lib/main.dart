import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/achievement_provider.dart';
import 'providers/break_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';

/// Key in SharedPreferences to track whether onboarding has been completed.
const String onboardingCompleteKey = 'onboardingComplete';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reschedule notifications on device reboot
  const bootChannel = MethodChannel('clarity_break/boot');
  bootChannel.setMethodCallHandler((call) async {
    if (call.method == 'onBootCompleted') {
      final svc = NotificationService();
      final enabled = await svc.loadRemindersEnabled();
      if (enabled) {
        final time = await svc.loadReminderTime();
        await svc.scheduleDailyReminder(time);
      }
    }
  });

  // Decide whether to show onboarding
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = !(prefs.getBool(onboardingCompleteKey) ?? false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BreakProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()..load()),
      ],
      child: ClarityBreakApp(showOnboarding: showOnboarding),
    ),
  );
}

/// Root widget. Chooses between Onboarding or Splash based on saved flag.
class ClarityBreakApp extends StatelessWidget {
  final bool showOnboarding;
  const ClarityBreakApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Clarity Break',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeProvider.mode,
      home: showOnboarding ? const OnboardingScreen() : const SplashScreen(),
    );
  }

  /// Builds a Material3-based theme from a seed color.
  ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final base = isLight ? ThemeData.light() : ThemeData.dark();
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC),
      brightness: brightness,
      primary: const Color(0xFF4DB6AC),
      secondary: const Color(0xFF81C784),
      tertiary: const Color(0xFFFFCCBC),
      background: isLight ? const Color(0xFFF5F5F5) : const Color(0xFF121212),
      surface: isLight ? Colors.white : const Color(0xFF1E1E1E),
      onPrimary: isLight ? Colors.white : Colors.black,
      onSecondary: isLight ? Colors.black : Colors.white,
      onBackground: isLight ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
      onSurface: isLight ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
      error: Colors.redAccent,
      onError: isLight ? Colors.white : Colors.black,
    );

    final textTheme = GoogleFonts.latoTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.displayLarge
            ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.textTheme.displayMedium
            ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineLarge
            ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      ),
    ).apply(
      bodyColor: cs.onBackground,
      displayColor: cs.onBackground,
    );

    return base.copyWith(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: cs.onSurface, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 1,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
          height: 1.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedIconTheme: IconThemeData(color: cs.primary, size: 24),
        unselectedIconTheme:
        IconThemeData(color: cs.onSurface.withOpacity(0.6), size: 24),
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))),
          overlayColor:
          MaterialStateProperty.all(cs.onPrimary.withOpacity(0.1)),
        ),
      ),

      // ← **FIX**: use CardThemeData not CardTheme
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cs.surface,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
      ),
    );
  }
}
