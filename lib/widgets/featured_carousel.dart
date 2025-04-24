// lib/widgets/featured_carousel.dart
import 'package:flutter/material.dart';
import '../models/library_article.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<LibraryArticle> featured;
  const FeaturedCarousel({required this.featured, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: featured.length,
        itemBuilder: (context, i) {
          final art = featured[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ArticleDetailScreen(article: art),
                  transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                ),
              ),
              child: Hero(
                tag: 'article_${art.id}',
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder image or color
                      Container(color: Theme.of(context).colorScheme.primaryContainer),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            art.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
