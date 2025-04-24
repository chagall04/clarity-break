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

  // Tag filtering
  List<String> _allTags = [];
  Set<String> _selectedTags = {};

  // Featured articles
  List<LibraryArticle> _featured = [];

  // Recent searches & views
  List<String> _recentSearches = [];
  List<LibraryArticle> _recentViews = [];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _libraryService.loadCategories().then((cats) {
      _allCategories = cats;
      _extractTagsAndFeatured();
      _loadRecents();
      _applyFilter();
      _startAutoScroll();
      return cats;
    });
    _searchController.addListener(() {
      _searchQuery = _searchController.text.trim();
      HistoryService().addSearch(_searchQuery);
      _loadRecentSearches();
      _applyFilter();
    });
    _loadRecentSearches();
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

  Future<void> _loadRecents() async {
    final ids = await HistoryService().getViews();
    final all = _allCategories.expand((c) => c.articles).toList();
    setState(() {
      _recentViews = ids
          .map((id) => all.firstWhereOrNull((a) => a.articleId == id))
          .whereType<LibraryArticle>()
          .toList();
    });
  }

  Future<void> _loadRecentSearches() async {
    final terms = await HistoryService().getSearches();
    setState(() {
      _recentSearches = terms;
    });
  }

  void _applyFilter() {
    final q = _searchQuery.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.map((cat) {
        final matchesCat = cat.title.toLowerCase().contains(q);
        final articles = cat.articles.where((a) {
          final inSearch = a.title.toLowerCase().contains(q) ||
              a.content.toLowerCase().contains(q);
          final inTag = _selectedTags.isEmpty
              ? true
              : a.tags.any(_selectedTags.contains);
          return inSearch && inTag;
        }).toList();
        if (matchesCat && _selectedTags.isEmpty && q.isEmpty) {
          return LibraryCategory(
            id: cat.id,
            title: cat.title,
            iconName: cat.iconName,
            articles: cat.articles,
          );
        }
        if (articles.isNotEmpty) {
          return LibraryCategory(
            id: cat.id,
            title: cat.title,
            iconName: cat.iconName,
            articles: articles,
          );
        }
        return null;
      }).whereType<LibraryCategory>().toList();
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
      case 'gavel':
        return Icons.gavel_outlined;
      case 'people':
        return Icons.people_outline;
      default:
        return Icons.book_outlined;
    }
  }

  void _openDetail(LibraryArticle art) {
    HistoryService().addView(art.articleId);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ArticleDetailScreen(article: art),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search articles…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _applyFilter(),
                ),
              ),

              // Recent searches
              if (_recentSearches.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    spacing: 6,
                    children: _recentSearches.map((term) {
                      return ActionChip(
                        label: Text(term),
                        onPressed: () {
                          _searchController.text = term;
                          _searchQuery = term;
                          _applyFilter();
                        },
                      );
                    }).toList(),
                  ),
                ),

              // Tags
              if (_allTags.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // Featured carousel + indicator
              if (_featured.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 200,
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onPanDown: (_) => _carouselTimer?.cancel(),
                            onPanEnd: (_) => _startAutoScroll(),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _featured.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentPage = i),
                              itemBuilder: (c, i) {
                                final art = _featured[i];
                                return _FeaturedCard(
                                  article: art,
                                  onTap: () => _openDetail(art),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _featured.length,
                          effect: WormEffect(
                            dotColor:
                            theme.colorScheme.onSurface.withOpacity(0.3),
                            activeDotColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Divider(height: 1),

              // Categories
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (ctx, idx) {
                    final cat = _filteredCategories[idx];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        leading: Icon(
                          _iconForCategory(cat.iconName),
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(cat.title,
                            style: theme.textTheme.titleMedium),
                        children: cat.articles.map((article) {
                          // build snippet
                          final snippet = article.content
                              .split('\n')
                              .firstWhereOrNull(
                                  (s) => s
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              ?.trim() ??
                              '';
                          return ListTile(
                            leading: FutureBuilder<bool>(
                              future: BookmarkService()
                                  .isBookmarked(article.articleId),
                              builder: (c, s) {
                                final bm = s.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    bm
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: bm
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                  onPressed: () async {
                                    await BookmarkService()
                                        .toggle(article.articleId);
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                            title: GestureDetector(
                              onTap: () => _openDetail(article),
                              child: Hero(
                                tag: 'hero-${article.articleId}',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: HighlightText(
                                    text: article.title,
                                    query: _searchQuery,
                                    style: theme.textTheme.bodyLarge,
                                    highlightStyle: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                        backgroundColor: theme
                                            .colorScheme.primary
                                            .withOpacity(0.2)),
                                  ),
                                ),
                              ),
                            ),
                            subtitle: snippet.isEmpty
                                ? null
                                : HighlightText(
                              text: '$snippet…',
                              query: _searchQuery,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6)),
                              highlightStyle: theme.textTheme.bodySmall
                                  ?.copyWith(
                                  backgroundColor: theme
                                      .colorScheme.primary
                                      .withOpacity(0.2)),
                            ),
                            trailing:
                            const Icon(Icons.chevron_right, size: 20),
                            onTap: () => _openDetail(article),
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

/// Helper featured card
class _FeaturedCard extends StatelessWidget {
  final LibraryArticle article;
  final VoidCallback onTap;
  const _FeaturedCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'hero-${article.articleId}',
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightText(
                    text: article.title,
                    query: '',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    article.tags.join(' • '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
