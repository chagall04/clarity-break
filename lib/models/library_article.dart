// lib/models/library_article.dart

class LibraryArticle {
  final String articleId;
  final String title;
  final String content;
  final List<String> tags;
  final bool featured;

  LibraryArticle({
    required this.articleId,
    required this.title,
    required this.content,
    this.tags = const [],
    this.featured = false,
  });

  factory LibraryArticle.fromJson(Map<String, dynamic> json) {
    return LibraryArticle(
      articleId: json['article_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((t) => t as String)
          .toList() ??
          [],
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'article_id': articleId,
    'title': title,
    'content': content,
    'tags': tags,
    'featured': featured,
  };
}
