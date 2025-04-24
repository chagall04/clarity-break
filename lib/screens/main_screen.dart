// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';        // Screen for the 'Home' tab
import 'library_screen.dart';    // Screen for the 'Library' tab
import 'journal_screen.dart';    // Screen for the 'Journal' tab
import 'history_screen.dart';    // Screen for the 'History' tab
import 'settings_screen.dart';   // <<<=== RE-ADD IMPORT for Settings

// This widget manages the main app layout with BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// State class for MainScreen
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index of the currently selected tab

  // List of the screens corresponding to each tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LibraryScreen(),
    JournalScreen(), // Journal Screen widget
    HistoryScreen(),
  ];

  // Titles for the AppBar corresponding to each tab
  static const List<String> _appBarTitles = <String>[
    'Clarity Break', // Title for Home tab
    'Knowledge Library', // Title for Library tab
    'My Journal', // Title for Journal Tab
    'Break History', // Title for History tab
  ];

  // Function called when a bottom navigation tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the state to switch tabs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]), // Dynamic title
        actions: [
          // Button to navigate to the Settings screen
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings', // Accessibility text
            onPressed: () {
              // Navigate to the SettingsScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        // Theme inherited from main.dart
      ),
      // Body uses IndexedStack for preserving state between tab switches
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      // Bottom navigation bar for switching main sections
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Filled icon when active
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem( // Journal Tab Item
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Journal',
          ),
          BottomNavigationBarItem( // History Tab Item
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the selected tab
        onTap: _onItemTapped, // Callback when a tab is tapped
        // Theme inherited from main.dart
      ),
    );
  }
}