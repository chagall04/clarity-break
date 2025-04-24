// lib/screens/article_list_screen.dart
import 'package:flutter/material.dart';
import '../models/library_category.dart'; // Category model
import '../models/library_article.dart'; // Article model
import 'article_detail_screen.dart'; // Screen to show article content

class ArticleListScreen extends StatelessWidget {
  final LibraryCategory category; // Receive the category to display

  const ArticleListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // Add an AppBar specific to this screen
      appBar: AppBar(
        title: Text(category.title), // Show category title in AppBar
        // backgroundColor: theme.colorScheme.surface, // Use theme's AppBar settings
        // foregroundColor: theme.colorScheme.onSurface,
        elevation: 1.0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: category.articles.length,
        itemBuilder: (context, index) {
          final article = category.articles[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              // Maybe add a simple leading icon like Icons.article_outlined
              leading: Icon(Icons.article_outlined, color: theme.colorScheme.secondary),
              title: Text(
                article.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              onTap: () {
                // Navigate to the ArticleDetailScreen, passing the selected article
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(article: article),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}