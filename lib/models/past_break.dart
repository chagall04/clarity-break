// lib/models/past_break.dart

// Represents a completed or ended tolerance break for the history list
class PastBreak {
  final DateTime startDate;
  final DateTime endDate;
  final int durationAchieved;      // Actual days completed
  final int intendedDuration;    // <<<=== NEW: Planned duration in days
  final String userWhy;           // User's reason for the break
  final bool completedFullDuration; // True if durationAchieved >= intendedDuration

  PastBreak({
    required this.startDate,
    required this.endDate,
    required this.durationAchieved,
    required this.intendedDuration, // <<<=== Add to constructor
    required this.userWhy,
    required this.completedFullDuration,
  });

  // Method to convert a PastBreak instance to a JSON map for storage
  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(), // Store dates as ISO strings
    'endDate': endDate.toIso8601String(),
    'durationAchieved': durationAchieved,
    'intendedDuration': intendedDuration, // <<<=== Add to JSON
    'userWhy': userWhy,
    'completedFullDuration': completedFullDuration,
  };

  // Factory constructor to create a PastBreak instance from a JSON map
  factory PastBreak.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int, providing a default value
    int safeParseInt(dynamic value, int defaultValue) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return PastBreak(
      // Parse ISO strings back to DateTime objects
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      durationAchieved: safeParseInt(json['durationAchieved'], 0),
      // <<<=== Parse intendedDuration, default to 28 if missing (for older data) ===>>>
      intendedDuration: safeParseInt(json['intendedDuration'], 28),
      userWhy: json['userWhy'] as String? ?? '', // Handle potential null/missing 'why'
      completedFullDuration: json['completedFullDuration'] as bool? ?? false, // Handle potential null
    );
  }
}