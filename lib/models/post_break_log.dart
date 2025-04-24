// lib/models/post_break_log.dart

// Represents a log entry for cannabis use after a tolerance break
class PostBreakLog {
  final DateTime date;
  final String amount; // e.g., "Low", "Medium", "High"
  final String notes;  // Optional user notes

  PostBreakLog({
    required this.date,
    required this.amount,
    this.notes = '', // Default to empty string
  });

  // Method to convert a PostBreakLog instance to a JSON map
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(), // Store date as ISO string
    'amount': amount,
    'notes': notes,
  };

  // Factory constructor to create a PostBreakLog instance from a JSON map
  factory PostBreakLog.fromJson(Map<String, dynamic> json) {
    return PostBreakLog(
      date: DateTime.parse(json['date'] as String), // Parse ISO string
      amount: json['amount'] as String? ?? 'Unknown', // Handle potential null
      notes: json['notes'] as String? ?? '', // Handle potential null
    );
  }
}