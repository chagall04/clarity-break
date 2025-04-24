// lib/screens/article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Import Markdown package
import '../models/library_article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final LibraryArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- Define Markdown Style customizations based on Theme ---
    final markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      // Increase base text size and line height
      p: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        fontSize: 16, // Apply base style to paragraphs
        color: theme.colorScheme.onBackground, // Ensure text color matches theme
      ),
      // Style bullet points
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        fontSize: 16, // Match paragraph style
        color: theme.colorScheme.onBackground,
      ),
      // Ensure bold text uses the correct color
      strong: const TextStyle(fontWeight: FontWeight.bold),
      // You can customize other elements like h1, h2, blockquote, etc.
      // h1: theme.textTheme.headlineLarge,
      // h2: theme.textTheme.headlineMedium,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        elevation: 1.0,
      ),
      body: SingleChildScrollView( // Keep SingleChildScrollView
        // Use MarkdownBody instead of Text
        child: MarkdownBody(
          data: article.content, // Pass the article content string
          selectable: true, // Allow users to select/copy text
          styleSheet: markdownStyleSheet, // Apply the custom styles
          // Handle links if you ever add them to your markdown
          // onTapLink: (text, href, title) {
          //   if (href != null) {
          //     // Use url_launcher package to open links
          //     // launchUrl(Uri.parse(href));
          //   }
          // },
        ),
        // Adjust padding for Markdown rendering if needed
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      ),
    );
  }
}