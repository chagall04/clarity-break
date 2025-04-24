// lib/models/library_category.dart
import 'library_article.dart';

class LibraryCategory {
  final String id;
  final String title;
  final String iconName; // Store icon hint from JSON
  final List<LibraryArticle> articles;

  LibraryCategory({
    required this.id,
    required this.title,
    required this.iconName,
    required this.articles,
  });

  // Factory constructor to create an instance from JSON
  factory LibraryCategory.fromJson(Map<String, dynamic> json) {
    // Parse the list of articles within the category
    var articleList = json['articles'] as List;
    List<LibraryArticle> articles = articleList
        .map((articleJson) => LibraryArticle.fromJson(articleJson))
        .toList();

    return LibraryCategory(
      id: json['category_id'] as String,
      title: json['category_title'] as String,
      iconName: json['category_icon'] as String, // Get icon hint
      articles: articles,
    );
  }
}