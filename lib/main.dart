// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Font styling package
import 'package:provider/provider.dart';       // State management package
import 'screens/splash_screen.dart';           // App splash screen
import 'providers/break_provider.dart';        // Break state management
import 'screens/main_screen.dart';             // Main navigation container

// Entry point of the application
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are ready
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
    // --- Define App Color Scheme ---
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC), // Base color for theme generation
      primary: const Color(0xFF4DB6AC),   // Primary UI color (Teal)
      secondary: const Color(0xFF81C784), // Secondary UI color (Green)
      tertiary: const Color(0xFFFFCCBC),  // Accent UI color (Peach)
      background: const Color(0xFFF5F5F5), // Default screen background
      surface: Colors.white,               // Card, dialog backgrounds
      onPrimary: Colors.white,             // Text on primary color
      onSecondary: Colors.black,           // Text on secondary color
      onTertiary: Colors.black,            // Text on tertiary color
      onBackground: const Color(0xFF424242), // Default text color
      onSurface: const Color(0xFF424242),   // Text on surface color
      onError: Colors.white,               // Text on error color
      error: Colors.redAccent,             // Error indication color
      brightness: Brightness.light,       // Use light theme mode
    );

    // --- Define Base Text Theme using Google Fonts ---
    final TextTheme baseTextTheme = GoogleFonts.latoTextTheme(
      ThemeData(brightness: Brightness.light).textTheme, // Base on default light styles
    );

    // --- Define Full App Theme ---
    final ThemeData themeData = ThemeData(
      useMaterial3: true, // Enable Material 3 design
      colorScheme: colorScheme, // Apply the defined colors
      scaffoldBackgroundColor: colorScheme.background, // Set default background

      // Apply custom fonts (Poppins for headings, Lato for body)
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
        displayMedium: GoogleFonts.poppins(textStyle: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
        displaySmall: GoogleFonts.poppins(textStyle: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        headlineLarge: GoogleFonts.poppins(textStyle: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600)), // SemiBold headings
        headlineMedium: GoogleFonts.poppins(textStyle: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
        headlineSmall: GoogleFonts.poppins(textStyle: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        titleLarge: GoogleFonts.poppins(textStyle: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        titleMedium: GoogleFonts.poppins(textStyle: baseTextTheme.titleMedium),
        titleSmall: GoogleFonts.poppins(textStyle: baseTextTheme.titleSmall),
        labelLarge: GoogleFonts.poppins(textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)), // Button text
      ).apply(
        bodyColor: colorScheme.onBackground, // Apply default text color
        displayColor: colorScheme.onBackground, // Apply heading text color
      ),

      // --- Specific Component Themes ---
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1.0, // Subtle shadow
        titleTextStyle: GoogleFonts.poppins( // Consistent AppBar title font
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary, // Selected item color
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), // Unselected item color
        backgroundColor: colorScheme.surface, // Nav bar background
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary, // Button background
          foregroundColor: colorScheme.onPrimary, // Button text color
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600), // Button font
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2.0, // Card shadow
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded card corners
        ),
        color: colorScheme.surface, // Card background color
      ),
      inputDecorationTheme: InputDecorationTheme( // Text field styling
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
    );

    // --- Root MaterialApp Widget ---
    return MaterialApp(
      title: 'Clarity Break',
      theme: themeData, // Apply the defined theme
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: const SplashScreen(), // Start with the splash screen
    );
  }
}