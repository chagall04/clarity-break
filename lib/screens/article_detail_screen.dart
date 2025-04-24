import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/library_article.dart';
import '../services/bookmark_service.dart';
import '../services/history_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final LibraryArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    // record view & load bookmark state
    HistoryService().addView(widget.article.articleId);
    BookmarkService()
        .isBookmarked(widget.article.articleId)
        .then((bm) => setState(() => _isBookmarked = bm));
  }

  Future<void> _toggleBookmark() async {
    await BookmarkService().toggle(widget.article.articleId);
    final bm = await BookmarkService().isBookmarked(widget.article.articleId);
    setState(() => _isBookmarked = bm);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
      listBullet: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
      strong: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'hero-${widget.article.articleId}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(widget.article.title,
                style: theme.textTheme.headlineSmall),
          ),
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: widget.article.content,
          selectable: true,
          styleSheet: markdownStyle,
        ),
      ),
    );
  }
}
