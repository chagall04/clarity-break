// lib/screens/article_list_screen.dart

import 'package:flutter/material.dart';
import '../models/library_category.dart';
import '../models/library_article.dart';
import 'article_detail_screen.dart';

class ArticleListScreen extends StatelessWidget {
  final LibraryCategory category;

  const ArticleListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(category.title), elevation: 1),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: category.articles.length,
        itemBuilder: (ctx, idx) {
          final art = category.articles[idx];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(Icons.article_outlined,
                  color: theme.colorScheme.secondary),
              title: Hero(
                tag: 'hero-${art.articleId}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(art.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(article: art)),
              ),
            ),
          );
        },
      ),
    );
  }
}
