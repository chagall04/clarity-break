// lib/services/library_service.dart
import 'dart:convert'; // For jsonDecode
import 'package:flutter/services.dart' show rootBundle; // To load assets
import '../models/library_category.dart';

class LibraryService {
  // Cache the loaded categories to avoid repeated file reading/parsing
  List<LibraryCategory>? _cachedCategories;

  // Load categories from the JSON asset file
  Future<List<LibraryCategory>> loadCategories() async {
    // Return cached data if available
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      // Load the JSON string from the asset file
      final String jsonString =
      await rootBundle.loadString('assets/data/library_content.json');

      // Decode the JSON string into a List<dynamic>
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Map the JSON list to a List<LibraryCategory> using the factory constructor
      _cachedCategories = jsonList
          .map((categoryJson) => LibraryCategory.fromJson(categoryJson))
          .toList();

      return _cachedCategories!;
    } catch (e) {
      // Handle potential errors during file loading or JSON parsing
      print('Error loading library content: $e');
      return []; // Return empty list on error
    }
  }
}