// lib/models/library_article.dart

class LibraryArticle {
  final String id;
  final String title;
  final String content;

  LibraryArticle({
    required this.id,
    required this.title,
    required this.content,
  });

  // Factory constructor to create an instance from JSON
  factory LibraryArticle.fromJson(Map<String, dynamic> json) {
    return LibraryArticle(
      id: json['article_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}