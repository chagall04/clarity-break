// lib/models/break_details.dart

/// Represents the state of a tolerance break.
class BreakDetails {
  final bool isActive;
  final DateTime? startDate;
  final String? userWhy;
  final int totalDuration;

  /// Default “no break” sentinel (duration field unused when inactive).
  static const BreakDetails none =
  BreakDetails(isActive: false, totalDuration: 28);

  const BreakDetails({
    required this.isActive,
    required this.totalDuration,
    this.startDate,
    this.userWhy,
  });

  /// Days passed since the break started (1-based).
  int get daysPassed {
    if (!isActive || startDate == null) return 0;
    final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day);
    final startDay = DateTime(
        startDate!.year, startDate!.month, startDate!.day);
    final diff = today.difference(startDay).inDays;
    return (diff < 0 ? 0 : diff) + 1;
  }

  /// Progress fraction (0.0–1.0) toward the planned duration.
  double get progress {
    if (!isActive || startDate == null || totalDuration <= 0) {
      return 0.0;
    }
    final cp = daysPassed;
    if (cp <= 0) return 0.0;
    if (cp > totalDuration) return 1.0;
    return cp / totalDuration;
  }
}
