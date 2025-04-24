import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart'; // We will create this next

void main() {
  // runApp starts the Flutter application
  runApp(const ClarityBreakApp());
}

// The root widget of the application
class ClarityBreakApp extends StatelessWidget {
  const ClarityBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the color scheme based on our plan
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC), // Primary Teal Color
      primary: const Color(0xFF4DB6AC),   // Teal
      secondary: const Color(0xFF81C784), // Muted Green
      tertiary: const Color(0xFFFFCCBC),  // Warm Sand/Peach (Accent)
      background: const Color(0xFFF5F5F5), // Off-White Background
      surface: Colors.white,               // Card backgrounds, dialogs etc.
      onPrimary: Colors.white,             // Text/icons on top of primary color
      onSecondary: Colors.black,           // Text/icons on top of secondary color
      onTertiary: Colors.black,            // Text/icons on top of accent color
      onBackground: const Color(0xFF424242), // Main text color on background
      onSurface: const Color(0xFF424242),   // Main text color on surface
      onError: Colors.white,
      error: Colors.redAccent,             // A standard error color
      brightness: Brightness.light,       // Use light theme mode
    );

    // Define the base text theme using Google Fonts
    final TextTheme baseTextTheme = GoogleFonts.latoTextTheme( // Body font
      ThemeData(brightness: Brightness.light).textTheme, // Start with default light theme text styles
    );

    // Define the final theme data
    final ThemeData themeData = ThemeData(
      useMaterial3: true, // Enable Material 3 features
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background, // Use the defined background color

      // Apply Google Fonts to the base text theme
      textTheme: baseTextTheme.copyWith(
        // Customize specific text styles if needed, using Poppins for headings
        displayLarge: GoogleFonts.poppins(textStyle: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
        displayMedium: GoogleFonts.poppins(textStyle: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
        displaySmall: GoogleFonts.poppins(textStyle: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        headlineLarge: GoogleFonts.poppins(textStyle: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600)), // SemiBold
        headlineMedium: GoogleFonts.poppins(textStyle: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
        headlineSmall: GoogleFonts.poppins(textStyle: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        titleLarge: GoogleFonts.poppins(textStyle: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        titleMedium: GoogleFonts.poppins(textStyle: baseTextTheme.titleMedium), // Keep default weight or adjust
        titleSmall: GoogleFonts.poppins(textStyle: baseTextTheme.titleSmall),
        // Body styles will inherit from Lato as set above
        // labelLarge is often used for buttons
        labelLarge: GoogleFonts.poppins(textStyle: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      ).apply(
        // Apply default text colors from the color scheme
        bodyColor: colorScheme.onBackground,
        displayColor: colorScheme.onBackground,
      ),

      // Customize other theme elements if needed
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface, // Or primary if you prefer colored AppBar
        foregroundColor: colorScheme.onSurface, // Text/icon color on AppBar
        elevation: 1.0, // Subtle elevation
        titleTextStyle: GoogleFonts.poppins( // Ensure AppBar title uses Poppins
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary, // Teal for selected item
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), // Greyish for unselected
        backgroundColor: colorScheme.surface, // Background color of the nav bar
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500), // Style for selected label
        unselectedLabelStyle: GoogleFonts.poppins(), // Style for unselected label
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary, // Teal background for buttons
          foregroundColor: colorScheme.onPrimary, // White text for buttons
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly rounded corners
          ),
        ),
      ),
      // Add other theme customizations (CardTheme, InputDecorations, etc.) as needed
    );

    // MaterialApp is the root visual widget container
    return MaterialApp(
      title: 'Clarity Break',
      theme: themeData, // Apply the theme we just defined
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: const MainScreen(), // Set the initial screen of the app
    );
  }
}