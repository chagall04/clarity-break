import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../services/library_service.dart';
import '../services/bookmark_service.dart';
import '../services/history_service.dart';
import '../models/library_category.dart';
import '../models/library_article.dart';
import '../widgets/highlight_text.dart';
import 'article_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  Future<List<LibraryCategory>>? _categoriesFuture;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _carouselTimer;
  int _currentPage = 0;

  List<LibraryCategory> _allCategories = [];
  List<LibraryCategory> _filteredCategories = [];
  List<String> _allTags = [];
  Set<String> _selectedTags = {};
  List<LibraryArticle> _featured = [];
  List<String> _recentSearches = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _libraryService.loadCategories().then((cats) {
      _allCategories = cats;
      _extractTagsAndFeatured();
      _applyFilter();
      _startAutoScroll();
      return cats;
    });
    _searchController.addListener(() {
      _searchQuery = _searchController.text.trim();
      HistoryService().addSearch(_searchQuery);
      _applyFilter();
    });
  }

  void _extractTagsAndFeatured() {
    final tags = <String>{};
    final featured = <LibraryArticle>[];
    for (var cat in _allCategories) {
      for (var art in cat.articles) {
        tags.addAll(art.tags);
        if (art.featured) featured.add(art);
      }
    }
    setState(() {
      _allTags = tags.toList()..sort();
      _featured = featured;
    });
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.map((cat) {
        final inCat = cat.title.toLowerCase().contains(q);
        final arts = cat.articles.where((a) {
          final inSearch = a.title.toLowerCase().contains(q) ||
              a.content.toLowerCase().contains(q);
          final inTag = _selectedTags.isEmpty
              ? true
              : a.tags.any(_selectedTags.contains);
          return inSearch && inTag;
        }).toList();
        if ((inCat && q.isEmpty && _selectedTags.isEmpty) || arts.isNotEmpty) {
          return LibraryCategory(
            id: cat.id,
            title: cat.title,
            iconName: cat.iconName,
            articles: q.isEmpty && _selectedTags.isEmpty ? cat.articles : arts,
          );
        }
        return null;
      }).whereNotNull().toList();
    });
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_featured.isEmpty) return;
      _currentPage = (_currentPage + 1) % _featured.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForCategory(String name) {
    switch (name) {
      case 'science':
        return Icons.science_outlined;
      case 'checklist':
        return Icons.checklist_rtl;
      case 'restart_alt':
        return Icons.restart_alt;
      default:
        return Icons.book_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Library'), elevation: 1),
      body: FutureBuilder<List<LibraryCategory>>(
        future: _categoriesFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search articles…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ),
              // Tag chips
              if (_allTags.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: _allTags.map((tag) {
                      final sel = _selectedTags.contains(tag);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: sel,
                          onSelected: (v) {
                            setState(() {
                              if (v) _selectedTags.add(tag);
                              else _selectedTags.remove(tag);
                              _applyFilter();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 8),
              // Featured carousel
              if (_featured.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: Column(children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _featured.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (c, i) {
                          final art = _featured[i];
                          return _FeaturedCard(article: art);
                        },
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _featured.length,
                      effect: WormEffect(
                        dotColor: theme.colorScheme.onSurface.withOpacity(0.3),
                        activeDotColor: theme.colorScheme.primary,
                      ),
                    )
                  ]),
                ),
              const Divider(),
              // Category list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (_, idx) {
                    final cat = _filteredCategories[idx];
                    return Card(
                      child: ExpansionTile(
                        leading: Icon(_iconForCategory(cat.iconName), color: theme.colorScheme.primary),
                        title: Text(cat.title),
                        children: cat.articles.map((a) {
                          return ListTile(
                            title: Text(a.title),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: a)),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Simplified featured card for carousel
class _FeaturedCard extends StatelessWidget {
  final LibraryArticle article;
  const _FeaturedCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(article.title, style: theme.textTheme.titleLarge),
          const Spacer(),
          Text(article.tags.join(' • '), style: theme.textTheme.bodySmall),
        ]),
      ),
    );
  }
}
