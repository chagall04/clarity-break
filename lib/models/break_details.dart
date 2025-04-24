// lib/models/break_details.dart

// Represents the state of a tolerance break
class BreakDetails {
  final bool isActive;
  final DateTime? startDate;
  final String? userWhy; // User's reason for the break
  // Add endDate or durationAchieved later for history

  // Constant for no active break
  static const BreakDetails none = BreakDetails(isActive: false);

  const BreakDetails({
    required this.isActive,
    this.startDate,
    this.userWhy,
  });

  // Helper method to calculate days passed since start
  int get daysPassed {
    if (!isActive || startDate == null) {
      return 0;
    }
    // Calculate difference in days, ignoring time component
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(startDate!.year, startDate!.month, startDate!.day);
    // Add 1 because day 1 starts immediately
    return today.difference(startDay).inDays + 1;
  }

  // Helper for progress calculation (0.0 to 1.0)
  double get progress {
    const totalDays = 28; // V1 fixed duration
    if (!isActive || startDate == null) {
      return 0.0;
    }
    int currentDay = daysPassed;
    if (currentDay <= 0) return 0.0;
    if (currentDay > totalDays) return 1.0; // Cap at 100%
    return currentDay / totalDays;
  }
}