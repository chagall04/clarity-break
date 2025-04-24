// lib/models/past_break.dart

// Represents a completed or ended tolerance break for history
class PastBreak {
  final DateTime startDate;
  final DateTime endDate;
  final int durationAchieved; // Days completed
  final String userWhy;        // Reason for the break
  final bool completedFullDuration; // True if reached 28 days

  PastBreak({
    required this.startDate,
    required this.endDate,
    required this.durationAchieved,
    required this.userWhy,
    required this.completedFullDuration,
  });

  // Method to convert a PastBreak instance to a JSON map
  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(), // Store dates as ISO strings
    'endDate': endDate.toIso8601String(),
    'durationAchieved': durationAchieved,
    'userWhy': userWhy,
    'completedFullDuration': completedFullDuration,
  };

  // Factory constructor to create a PastBreak instance from a JSON map
  factory PastBreak.fromJson(Map<String, dynamic> json) {
    return PastBreak(
      // Parse ISO strings back to DateTime objects
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      durationAchieved: json['durationAchieved'] as int,
      userWhy: json['userWhy'] as String? ?? '', // Handle potential null/missing 'why'
      completedFullDuration: json['completedFullDuration'] as bool? ?? false, // Handle potential null
    );
  }
}