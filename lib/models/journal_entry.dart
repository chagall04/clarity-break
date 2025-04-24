// lib/models/journal_entry.dart

// Enum to define the type of journal entry
enum JournalEntryType { checkIn, usage, abstinence }

// Unified model for all journal entry types
class JournalEntry {
  final String id; // Unique ID for each entry
  final DateTime date;
  final JournalEntryType entryType;

  // Check-in specific fields (nullable)
  final int? moodRating; // e.g., 1-5
  final List<String>? changesNoticed; // List of tags like "+Clear Mind", "-Irritability"
  final bool? cravingsPresentCheckin; // Simple Yes/No for check-in

  // Usage specific fields (nullable)
  final String? usageAmount; // "Low", "Medium", "High"
  final String? usageType; // "Flower", "Vape", etc.
  final String? usagePotency; // "Low", "Medium", "High"
  final List<String>? usageEffects; // List of tags like "Relaxed", "Creative"
  final int? moodRatingUsage; // Separate mood rating associated with usage

  // Abstinence specific fields (nullable)
  final bool? cravingsPresentAbstinence; // Yes/No/Maybe for non-use days

  // Common field
  final String notes;

  JournalEntry({
    required this.id,
    required this.date,
    required this.entryType,
    this.moodRating,
    this.changesNoticed,
    this.cravingsPresentCheckin,
    this.usageAmount,
    this.usageType,
    this.usagePotency,
    this.usageEffects,
    this.moodRatingUsage,
    this.cravingsPresentAbstinence,
    this.notes = '',
  });

  // --- JSON Serialization ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'entryType': entryType.name, // Store enum name as string
    'moodRating': moodRating,
    'changesNoticed': changesNoticed,
    'cravingsPresentCheckin': cravingsPresentCheckin,
    'usageAmount': usageAmount,
    'usageType': usageType,
    'usagePotency': usagePotency,
    'usageEffects': usageEffects,
    'moodRatingUsage': moodRatingUsage,
    'cravingsPresentAbstinence': cravingsPresentAbstinence,
    'notes': notes,
  };

  // --- JSON Deserialization ---
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse enum string
    JournalEntryType parseEntryType(String? name) {
      return JournalEntryType.values
          .firstWhere((e) => e.name == name, orElse: () => JournalEntryType.checkIn); // Default or throw error
    }

    return JournalEntry(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(), // Provide default ID if missing
      date: DateTime.parse(json['date'] as String),
      entryType: parseEntryType(json['entryType'] as String?),
      moodRating: json['moodRating'] as int?,
      // Ensure lists are parsed correctly (List<dynamic> -> List<String>)
      changesNoticed: (json['changesNoticed'] as List<dynamic>?)?.map((item) => item as String).toList(),
      cravingsPresentCheckin: json['cravingsPresentCheckin'] as bool?,
      usageAmount: json['usageAmount'] as String?,
      usageType: json['usageType'] as String?,
      usagePotency: json['usagePotency'] as String?,
      usageEffects: (json['usageEffects'] as List<dynamic>?)?.map((item) => item as String).toList(),
      moodRatingUsage: json['moodRatingUsage'] as int?,
      cravingsPresentAbstinence: json['cravingsPresentAbstinence'] as bool?,
      notes: json['notes'] as String? ?? '',
    );
  }
}