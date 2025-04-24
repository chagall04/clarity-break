// lib/screens/library_screen.dart
import 'package:flutter/material.dart';
import '../services/library_service.dart'; // Import service
import '../models/library_category.dart'; // Import model
import 'article_list_screen.dart'; // Screen to show articles in a category

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  Future<List<LibraryCategory>>? _categoriesFuture; // Future to hold data

  @override
  void initState() {
    super.initState();
    // Load categories when the screen initializes
    _categoriesFuture = _libraryService.loadCategories();
  }

  // Helper to get an icon based on the name hint from JSON
  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'science':
        return Icons.science_outlined;
      case 'checklist':
        return Icons.checklist_rtl_outlined;
      case 'restart_alt':
        return Icons.restart_alt_outlined;
      default:
        return Icons.library_books_outlined; // Default icon
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // AppBar is handled by MainScreen
      body: FutureBuilder<List<LibraryCategory>>(
        future: _categoriesFuture, // Use the future initialized in initState
        builder: (context, snapshot) {
          // --- Handle different states of the Future ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while data is loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if loading failed
            print('LibraryScreen Error: ${snapshot.error}'); // Log error
            return Center(
              child: Text(
                'Could not load library content.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show message if no data is available
            return Center(
              child: Text(
                'No library content available.',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
            );
          } else {
            // --- Data loaded successfully, build the list ---
            final categories = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0), // Add padding around the list
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  // Use CardTheme from main.dart
                  clipBehavior: Clip.antiAlias, // Ensures InkWell ripple stays inside card
                  child: ListTile(
                    leading: Icon(
                      _getIconForCategory(category.iconName), // Use helper for icon
                      color: theme.colorScheme.primary, // Teal icon color
                      size: 32,
                    ),
                    title: Text(
                      category.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600, // Slightly bolder title
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onTap: () {
                      // Navigate to the ArticleListScreen, passing the selected category
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleListScreen(category: category),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}