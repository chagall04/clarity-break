import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'history_screen.dart';
// Import settings screen later if needed via AppBar icon

// This widget manages the main navigation tabs (Home, Library, History)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index of the currently selected tab
  int _selectedIndex = 0;

  // List of the widgets (screens) to display for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    LibraryScreen(),
    HistoryScreen(),
  ];

  // List of titles corresponding to each screen for the AppBar
  static const List<String> _appBarTitles = <String>[
    'Clarity Break', // Or maybe dynamic based on break status later
    'Knowledge Library',
    'Break History',
  ];

  // Function called when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar that changes title based on the selected tab
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        // Optionally add a settings icon button later
        // actions: [
        //   if (_selectedIndex == 0) // Show only on Home perhaps
        //     IconButton(
        //       icon: Icon(Icons.settings),
        //       onPressed: () {
        //         // Navigate to SettingsScreen
        //       },
        //     ),
        // ],
      ),
      // Body displays the widget corresponding to the selected tab index
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Use filled icon when active
            label: 'Home',
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
        currentIndex: _selectedIndex, // Highlights the current tab
        // selectedItemColor: Theme.of(context).colorScheme.primary, // Handled by theme
        onTap: _onItemTapped, // Callback when a tab is tapped
        // type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      ),
    );
  }
}