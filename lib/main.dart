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
  await NotificationService().initialize(); // Initialize notifications (can stay here)
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
      // Specific container colors for chips etc.
      primaryContainer: Color.lerp(const Color(0xFF4DB6AC), Colors.white, 0.85),
      secondaryContainer: Color.lerp(const Color(0xFF81C784), Colors.white, 0.85),
      tertiaryContainer: Color.lerp(const Color(0xFFFFCCBC), Colors.white, 0.85),
      errorContainer: Color.lerp(Colors.redAccent[100]!, Colors.white, 0.8),
      surfaceVariant: Colors.grey.shade200, // Subtle variant for surfaces like unselected chips
      onPrimaryContainer: const Color(0xFF003D37), // Text on primaryContainer
      onSecondaryContainer: const Color(0xFF0B3E10), // Text on secondaryContainer
      onTertiaryContainer: const Color(0xFF542A1A), // Text on tertiaryContainer
      onErrorContainer: const Color(0xFF630000), // Text on errorContainer
      onSurfaceVariant: Colors.grey.shade700, // Text on surfaceVariant
    );

    // --- Define Dark Color Scheme ---
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4DB6AC), // Keep same seed color
      brightness: Brightness.dark,        // Specify Dark Mode
      primary: const Color(0xFF66D9C4),   // Lighter Teal for dark mode contrast
      secondary: const Color(0xFF9CCC65), // Lighter Green
      tertiary: const Color(0xFFFFAB91),  // Lighter Peach/Sand
      background: const Color(0xFF121212), // Common dark background
      surface: const Color(0xFF1E1E1E),   // Slightly lighter surface for cards/dialogs
      onPrimary: Colors.black,             // Text on primary
      onSecondary: Colors.black,           // Text on secondary
      onTertiary: Colors.black,            // Text on tertiary
      onBackground: const Color(0xFFE0E0E0), // Light text on dark background
      onSurface: const Color(0xFFE0E0E0),   // Light text on dark surface
      onError: Colors.black,
      error: Colors.redAccent[100]!,        // Use a lighter red that contrasts well
      // Specific container colors for chips etc. in dark mode
      primaryContainer: const Color(0xFF005047),
      secondaryContainer: const Color(0xFF2E5123),
      tertiaryContainer: const Color(0xFF713F2E),
      errorContainer: const Color(0xFF8C1D18),
      surfaceVariant: Colors.grey.shade800, // Darker variant for surfaces
      onPrimaryContainer: const Color(0xFF87F7E1), // Text on primaryContainer
      onSecondaryContainer: const Color(0xFFB7E9A4), // Text on secondaryContainer
      onTertiaryContainer: const Color(0xFFFFDBCF), // Text on tertiaryContainer
      onErrorContainer: const Color(0xFFFFDAD6), // Text on errorContainer
      onSurfaceVariant: Colors.grey.shade400, // Text on surfaceVariant
    );


    // --- Function to build ThemeData (Light or Dark) ---
    // This helper function creates ThemeData based on a ColorScheme and Brightness
    ThemeData buildTheme(ColorScheme colorScheme, Brightness brightness) {
      final currentBaseTextTheme = GoogleFonts.latoTextTheme(
        ThemeData(brightness: brightness).textTheme, // Base fonts on correct brightness
      );
      return ThemeData(
        useMaterial3: true, // Enable Material 3 features
        colorScheme: colorScheme, // Apply the passed ColorScheme
        scaffoldBackgroundColor: colorScheme.background, // Default screen background

        // Define Text Styles using GoogleFonts
        textTheme: currentBaseTextTheme.copyWith(
          // Apply Poppins to headings and labels
          displayLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
          displayMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
          displaySmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
          headlineLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600)),
          headlineMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600)),
          headlineSmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
          titleLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          titleMedium: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleMedium),
          titleSmall: GoogleFonts.poppins(textStyle: currentBaseTextTheme.titleSmall),
          labelLarge: GoogleFonts.poppins(textStyle: currentBaseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)), // Used for buttons
          // Use Lato for smaller labels (body text default is Lato)
          labelMedium: GoogleFonts.lato(textStyle: currentBaseTextTheme.labelMedium),
          labelSmall: GoogleFonts.lato(textStyle: currentBaseTextTheme.labelSmall),
        ).apply( // Apply default text colors FROM THE SCHEME
          bodyColor: colorScheme.onBackground,
          displayColor: colorScheme.onBackground,
        ),

        // --- Specific Component Themes ---
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface, // Use surface color
          foregroundColor: colorScheme.onSurface, // Text/icon color
          elevation: 0, // Flat AppBar for modern look
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: colorScheme.primary, // Color for selected tab item
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), // Color for unselected items
          backgroundColor: colorScheme.surface, // Nav bar background (match AppBar)
          elevation: 0, // Flat bottom nav bar
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary, // Button background
            foregroundColor: colorScheme.onPrimary, // Button text color
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Consistent rounding
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData( // Style for FilledButtons
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary, // Use primary color
              foregroundColor: colorScheme.onPrimary, // Text color on primary
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            )
        ),
        textButtonTheme: TextButtonThemeData( // Style for TextButtons
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary, // Default color
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )
        ),
        cardTheme: CardTheme(
          elevation: brightness == Brightness.light ? 1.5 : 1.0, // Subtle elevation based on mode
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Consistent rounding
          ),
          color: colorScheme.surface, // Use surface color for cards
          clipBehavior: Clip.antiAlias, // Clip ripple effect
        ),
        chipTheme: ChipThemeData( // Unified styling for all Chips
          backgroundColor: colorScheme.surfaceVariant, // Background for unselected/filter chips
          selectedColor: colorScheme.secondaryContainer, // Background for selected ChoiceChips/FilterChips
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12), // Text style for unselected
          secondaryLabelStyle: TextStyle(color: colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w500), // Text style for selected
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none, // No border
          padding: const EdgeInsets.symmetric(horizontal: 10.0), // Adjust padding
          iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 16),
          visualDensity: VisualDensity.compact, // Make chips compact
        ),
        inputDecorationTheme: InputDecorationTheme( // Styling for TextFields
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.6), // Use surface variant for fill
          border: OutlineInputBorder( // Default border style
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // No border when not focused (filled style)
          ),
          enabledBorder: OutlineInputBorder( // Border when enabled (subtle)
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder( // Border when focused (use primary color)
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)), // Label text style
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)), // Hint text style
        ),
        dividerTheme: DividerThemeData( // Styling for Dividers
          color: colorScheme.onSurface.withOpacity(0.12), // Subtle divider color
          space: 1,
          thickness: 1,
        ),
        dialogTheme: DialogTheme( // Styling for Dialogs
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded dialog corners
          elevation: 3,
          titleTextStyle: GoogleFonts.poppins(textStyle: currentBaseTextTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)), // Dialog title style
          contentTextStyle: GoogleFonts.lato(textStyle: currentBaseTextTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), // Dialog content style
        ),
      );
    }

    // --- Root MaterialApp Widget ---
    return MaterialApp(
      title: 'Clarity Break',
      // *** APPLY THEMES AND THEME MODE ***
      theme: buildTheme(lightColorScheme, Brightness.light), // Provide Light Theme
      darkTheme: buildTheme(darkColorScheme, Brightness.dark), // Provide Dark Theme
      themeMode: ThemeMode.system, // Automatically switch based on system setting
      debugShowCheckedModeBanner: false, // Hide debug banner
      home: const SplashScreen(), // Start with the splash screen
    );
  }
}