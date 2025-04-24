// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Font styling package
import 'package:provider/provider.dart';       // State management package
import 'screens/splash_screen.dart';           // App splash screen
import 'providers/break_provider.dart';        // Break state management
import 'screens/main_screen.dart';             // Needed by SplashScreen import below
import 'services/notification_service.dart';   // For initializing notifications

// Entry point of the application
Future<void> main() async { // Make main async for initialization
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are ready
  await NotificationService().initialize(); // Initialize notifications
  runApp(
    // Provide BreakProvider state to the widget tree
    ChangeNotifierProvider(
      create: (context) => BreakProvider(),
      child: const ClarityBreakApp(), // Root application widget
    ),
  );
}

// Root application widget definition
class ClarityBreakApp extends StatelessWidget {
  const ClarityBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Define Light Color Scheme ---
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC), // Base color for theme generation
      brightness: Brightness.light,       // Specify Light Mode
      primary: const Color(0xFF4DB6AC),   // Teal
      secondary: const Color(0xFF81C784), // Muted Green
      tertiary: const Color(0xFFFFCCBC),  // Warm Sand/Peach
      background: const Color(0xFFF5F5F5), // Off-White Background
      surface: Colors.white,               // Card backgrounds, dialogs etc.
      onPrimary: Colors.white,             // Text on primary color
      onSecondary: Colors.black,           // Text on secondary color
      onTertiary: Colors.black,            // Text on tertiary color
      onBackground: const Color(0xFF424242), // Dark text on light background
      onSurface: const Color(0xFF424242),   // Dark text on light surface
      onError: Colors.white,
      error: Colors.redAccent[100]!,        // Lighter error color for light theme
      primaryContainer: Color.lerp(const Color(0xFF4DB6AC), Colors.white, 0.85),
      secondaryContainer: Color.lerp(const Color(0xFF81C784), Colors.white, 0.85),
      tertiaryContainer: Color.lerp(const Color(0xFFFFCCBC), Colors.white, 0.85),
      errorContainer: Color.lerp(Colors.redAccent[100]!, Colors.white, 0.8),
      surfaceVariant: Colors.grey.shade200,
      onPrimaryContainer: const Color(0xFF003D37),
      onSecondaryContainer: const Color(0xFF0B3E10),
      onTertiaryContainer: const Color(0xFF542A1A),
      onErrorContainer: const Color(0xFF630000),
      onSurfaceVariant: Colors.grey.shade700,
    );

    // --- Define Dark Color Scheme ---
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC),
      brightness: Brightness.dark,
      primary: const Color(0xFF66D9C4),   // Lighter Teal
      secondary: const Color(0xFF9CCC65), // Lighter Green
      tertiary: const Color(0xFFFFAB91),  // Lighter Peach
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onTertiary: Colors.black,
      onBackground: const Color(0xFFE0E0E0),
      onSurface: const Color(0xFFE0E0E0),
      onError: Colors.black,
      error: Colors.redAccent[100]!,
      primaryContainer: const Color(0xFF005047),
      secondaryContainer: const Color(0xFF2E5123),
      tertiaryContainer: const Color(0xFF713F2E),
      errorContainer: const Color(0xFF8C1D18),
      surfaceVariant: Colors.grey.shade800,
      onPrimaryContainer: const Color(0xFF87F7E1),
      onSecondaryContainer: const Color(0xFFB7E9A4),
      onTertiaryContainer: const Color(0xFFFFDBCF),
      onErrorContainer: const Color(0xFFFFDAD6),
      onSurfaceVariant: Colors.grey.shade400,
    );


    // --- Function to build ThemeData (Light or Dark) ---
    ThemeData buildTheme(ColorScheme colorScheme, Brightness brightness) {
      final currentBaseTextTheme = GoogleFonts.latoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      );
      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        textTheme: currentBaseTextTheme.copyWith( // Define text styles
          displayLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
          // ... other text styles using GoogleFonts.poppins or lato ...
          displayMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          displaySmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
          headlineLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600)),
          headlineMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
          headlineSmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          titleLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          titleMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleMedium),
          titleSmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleSmall),
          labelLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          labelMedium: GoogleFonts.lato(textStyle: currentBaseTextTheme.labelMedium),
          labelSmall: GoogleFonts.lato(textStyle: currentBaseTextTheme.labelSmall),
        ).apply(
          bodyColor: colorScheme.onBackground,
          displayColor: colorScheme.onBackground,
        ),
        // --- Component Themes ---
        appBarTheme: AppBarTheme( // Style AppBar
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0, // Flat AppBar
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData( // Style Bottom Nav Bar
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: colorScheme.surface,
          elevation: 0, // Flat Bottom Nav
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Style Elevated Buttons
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData( // Style Filled Buttons
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            )
        ),
        textButtonTheme: TextButtonThemeData( // Style Text Buttons
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )
        ),
        cardTheme: CardTheme( // Style Cards
          elevation: brightness == Brightness.light ? 1.5 : 1.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: colorScheme.surface,
          clipBehavior: Clip.antiAlias,
        ),
        chipTheme: ChipThemeData( // Style Chips
          backgroundColor: colorScheme.surfaceVariant,
          selectedColor: colorScheme.secondaryContainer,
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 16),
          // *** FIX: Removed visualDensity from ChipThemeData ***
          // visualDensity: VisualDensity.compact, // Apply density individually if needed
        ),
        inputDecorationTheme: InputDecorationTheme( // Style TextFields
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        ),
        dividerTheme: DividerThemeData( // Style Dividers
          color: colorScheme.onSurface.withOpacity(0.12),
          space: 1,
          thickness: 1,
        ),
        dialogTheme: DialogTheme( // Style Dialogs
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          titleTextStyle: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
          contentTextStyle: GoogleFonts.lato(textStyle: currentBaseTextTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
        ),
      );
    }

    // --- Root MaterialApp Widget ---
    return MaterialApp(
      title: 'Clarity Break',
      theme: buildTheme(lightColorScheme, Brightness.light), // Provide Light Theme
      darkTheme: buildTheme(darkColorScheme, Brightness.dark), // Provide Dark Theme
      themeMode: ThemeMode.system, // Follow system setting
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: const SplashScreen(), // Start with the splash screen
    );
  }
}