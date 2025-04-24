// lib/screens/library_screen.dart
import 'package:flutter/material.dart';
import '../services/library_service.dart'; // Service to load categories/articles
import '../models/library_category.dart'; // Category model
import '../models/library_article.dart';  // Article model (needed for filtering results)
import 'article_list_screen.dart';    // Screen to show articles in a category
import 'article_detail_screen.dart'; // Screen to show individual article detail

// Screen displaying knowledge library categories and search functionality
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  Future<List<LibraryCategory>>? _categoriesFuture; // Future for initial category load
  List<LibraryCategory> _allCategories = []; // Stores all loaded categories
  List<dynamic> _searchResults = []; // Stores filtered results (can be categories or articles)
  String _searchQuery = ''; // Current search text
  final TextEditingController _searchController = TextEditingController(); // Controller for search field

  @override
  void initState() {
    super.initState();
    // Load categories when the screen initializes
    _categoriesFuture = _libraryService.loadCategories().then((categories) {
      setState(() {
        _allCategories = categories; // Store all categories once loaded
        _filterResults(); // Initially show all categories
      });
      return categories; // Return for FutureBuilder
    });

    // Listen to changes in the search field
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _filterResults(); // Re-filter results when query changes
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller when screen is removed
    super.dispose();
  }

  // Filter categories and articles based on the search query
  void _filterResults() {
    if (_searchQuery.isEmpty) {
      // If query is empty, show all categories
      _searchResults = List.from(_allCategories); // Make a copy
    } else {
      final queryLower = _searchQuery.toLowerCase();
      List<dynamic> results = [];
      // Search through categories and their articles
      for (var category in _allCategories) {
        bool categoryMatch = category.title.toLowerCase().contains(queryLower);
        List<LibraryArticle> matchingArticles = [];

        for (var article in category.articles) {
          if (article.title.toLowerCase().contains(queryLower) ||
              article.content.toLowerCase().contains(queryLower)) {
            matchingArticles.add(article);
          }
        }
        // Add category if it matches OR if it has matching articles
        if (categoryMatch || matchingArticles.isNotEmpty) {
          // If only articles matched, add category header first
          if (!results.contains(category) && matchingArticles.isNotEmpty && !categoryMatch) {
            // Add a special marker or the category itself to indicate a header is needed
            // For simplicity, let's just add the category if articles match
            if (!results.contains(category)) {
              results.add(category); // Add category header if needed
            }
          } else if (categoryMatch) {
            if (!results.contains(category)) {
              results.add(category); // Add category if title matches
            }
          }
          // Add all matching articles under this category
          results.addAll(matchingArticles);
        }
      }
      _searchResults = results;
    }
  }


  // Helper to get an icon based on the name hint from JSON
  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'science': return Icons.science_outlined;
      case 'checklist': return Icons.checklist_rtl_outlined;
      case 'restart_alt': return Icons.restart_alt_outlined;
      default: return Icons.library_books_outlined;
    }
  }

  // Find the category an article belongs to (needed for navigation)
  LibraryCategory? _findCategoryForArticle(LibraryArticle article) {
    for (var category in _allCategories) {
      if (category.articles.any((a) => a.id == article.id)) {
        return category;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // AppBar handled by MainScreen, but we add a search field below it
      body: Column( // Use Column to stack Search Field + List
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Library...',
                prefixIcon: const Icon(Icons.search),
                // Use filled style for modern look
                // filled: true, // Style from theme
                // fillColor: theme.inputDecorationTheme.fillColor, // Style from theme
                // border: InputBorder.none, // Style from theme (usually OutlineInputBorder)
                // focusedBorder: InputBorder.none, // Style from theme
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), // Adjust padding
                // Add clear button
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear(); // Clears text and triggers listener
                  },
                )
                    : null,
              ),
            ),
          ),

          // --- Results List ---
          Expanded( // Make the list take remaining space
            child: FutureBuilder<List<LibraryCategory>>(
              // FutureBuilder still useful for initial loading state
              future: _categoriesFuture,
              builder: (context, snapshot) {
                // Handle loading state
                if (_allCategories.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Handle error state
                if (snapshot.hasError) {
                  print('LibraryScreen Error: ${snapshot.error}');
                  return Center(child: Text('Could not load library content.', style: TextStyle(color: theme.colorScheme.error)));
                }
                // Handle empty results after search
                if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text(
                      'No results found for "$_searchQuery"',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                // Handle initial empty state (before search) - shouldn't happen if JSON has content
                if (_searchResults.isEmpty && _searchQuery.isEmpty && _allCategories.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                  return Center(child: Text('Library is empty.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.7))));
                }


                // --- Build the list based on search results ---
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0), // Adjust padding
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];

                    // --- Display Category Header ---
                    if (item is LibraryCategory) {
                      // Show full category card only if NOT searching OR if category title matches
                      bool showFullCard = _searchQuery.isEmpty || item.title.toLowerCase().contains(_searchQuery.toLowerCase());

                      if (showFullCard) {
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: Icon(_getIconForCategory(item.iconName), color: theme.colorScheme.primary, size: 32),
                            title: Text(item.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleListScreen(category: item)));
                            },
                          ),
                        );
                      } else {
                        // If category doesn't match but contains matching articles, show a minimal header
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                          child: Text(
                            item.title, // Category title as header
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                          ),
                        );
                      }
                    }
                    // --- Display Article Result ---
                    else if (item is LibraryArticle) {
                      // Find the category this article belongs to for context if needed
                      final category = _findCategoryForArticle(item);
                      return ListTile(
                        // dense: true, // Make article results more compact
                        leading: const Icon(Icons.article_outlined, size: 20),
                        title: Text(item.title),
                        subtitle: category != null ? Text(category.title, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary.withOpacity(0.8))) : null, // Show category context
                        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: item)));
                        },
                      );
                    }
                    // Fallback for unexpected item types
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}