// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';        // Screen for the 'Home' tab
import 'library_screen.dart';    // Screen for the 'Library' tab
import 'history_screen.dart';    // Screen for the 'History' tab

// This widget manages the main app layout with BottomNavigationBar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index of the currently selected tab

  // List of the screens corresponding to each tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LibraryScreen(),
    HistoryScreen(),
  ];

  // Titles for the AppBar corresponding to each tab
  static const List<String> _appBarTitles = <String>[
    'Clarity Break', // Title for Home tab
    'Knowledge Library', // Title for Library tab
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
      // AppBar displays title based on the selected tab
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        // AppBar theme is inherited from main.dart
      ),
      // Body displays the screen widget for the current index
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Bottom navigation bar for switching sections
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Default icon
            activeIcon: Icon(Icons.home),     // Icon when selected
            label: 'Home',                   // Tab label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex, // Highlight the current tab
        onTap: _onItemTapped, // Set the callback for tap events
        // Theme for colors/styles is inherited from main.dart
      ),
    );
  }
}