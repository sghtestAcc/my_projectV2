// lib/utils/medication_refill_calculator.dart
class MedicationRefillCalculator {
  /// Calculate when to send refill notification based on quantity and instructions
  /// Returns notification date (2 days before medication runs out)
  static DateTime? calculateRefillNotificationDate({
    required String quantity,
    required String instructions,
    DateTime? startDate,
  }) {
    try {
      // Parse quantity (e.g., "10 tablets", "30 pills", "100 mg")
      final quantityNumber = _extractQuantityNumber(quantity);
      if (quantityNumber == null) return null;

      // Parse instructions to get daily dosage
      final dailyDosage = _parseDailyDosage(instructions);
      if (dailyDosage == null) return null;

      // Calculate how many days the medication will last
      final daysSupply = (quantityNumber / dailyDosage).floor();
      
      // Set notification 2 days before running out
      final bufferDays = 2;
      final notificationDays = daysSupply - bufferDays;
      
      // If medication runs out too quickly, notify immediately
      if (notificationDays <= 0) return DateTime.now().add(Duration(hours: 1));
      
      final medicationStartDate = startDate ?? DateTime.now();
      return medicationStartDate.add(Duration(days: notificationDays));
      
    } catch (e) {
      print('Error calculating refill date: $e');
      return null;
    }
  }

  /// Extract number from quantity string (e.g., "10 tablets" -> 10)
  static int? _extractQuantityNumber(String quantity) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(quantity.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Parse daily dosage from instructions with enhanced patterns
  static double? _parseDailyDosage(String instructions) {
    final instructionsLower = instructions.toLowerCase();
    
    // Pattern 1: "take X tablet(s) Y times a day"
    final pattern1 = RegExp(r'take\s+(\d+)\s+.*?(\d+)\s+times?\s+(?:a\s+)?day');
    var match = pattern1.firstMatch(instructionsLower);
    if (match != null) {
      final tabletsPerDose = int.tryParse(match.group(1)!) ?? 1;
      final timesPerDay = int.tryParse(match.group(2)!) ?? 1;
      return (tabletsPerDose * timesPerDay).toDouble();
    }

    // Pattern 2: "X tablet(s) Y times daily"
    final pattern2 = RegExp(r'(\d+)\s+.*?(\d+)\s+times?\s+daily');
    match = pattern2.firstMatch(instructionsLower);
    if (match != null) {
      final tabletsPerDose = int.tryParse(match.group(1)!) ?? 1;
      final timesPerDay = int.tryParse(match.group(2)!) ?? 1;
      return (tabletsPerDose * timesPerDay).toDouble();
    }

    // Pattern 3: "take X every Y hours"
    final pattern3 = RegExp(r'take\s+(\d+).*?every\s+(\d+)\s+hours?');
    match = pattern3.firstMatch(instructionsLower);
    if (match != null) {
      final tabletsPerDose = int.tryParse(match.group(1)!) ?? 1;
      final hoursInterval = int.tryParse(match.group(2)!) ?? 24;
      final dosesPerDay = 24 / hoursInterval;
      return tabletsPerDose * dosesPerDay;
    }

    // Pattern 4: "X daily" or "X per day"
    final pattern4 = RegExp(r'(\d+)\s+(?:daily|per\s+day)');
    match = pattern4.firstMatch(instructionsLower);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    // Pattern 5: Common phrases
    if (instructionsLower.contains('once daily') || instructionsLower.contains('once a day')) {
      return 1.0;
    }
    if (instructionsLower.contains('twice daily') || instructionsLower.contains('twice a day')) {
      return 2.0;
    }
    if (instructionsLower.contains('three times daily') || instructionsLower.contains('thrice daily')) {
      return 3.0;
    }
    if (instructionsLower.contains('four times daily')) {
      return 4.0;
    }

    // Pattern 6: "every X days" (less frequent dosing)
    final pattern6 = RegExp(r'every\s+(\d+)\s+days?');
    match = pattern6.firstMatch(instructionsLower);
    if (match != null) {
      final dayInterval = int.tryParse(match.group(1)!) ?? 1;
      return 1.0 / dayInterval; // e.g., every 3 days = 0.33 per day
    }

    // Default: assume once daily if unclear
    print('Could not parse dosage from: $instructions, defaulting to once daily');
    return 1.0;
  }

  /// Get a human-readable description of the calculation
  static String getCalculationDescription({
    required String quantity,
    required String instructions,
  }) {
    final quantityNumber = _extractQuantityNumber(quantity);
    final dailyDosage = _parseDailyDosage(instructions);
    
    if (quantityNumber == null || dailyDosage == null) {
      return 'Unable to calculate refill timing';
    }

    final daysSupply = (quantityNumber / dailyDosage).floor();
    return 'With $quantity and taking $dailyDosage per day, medication will last $daysSupply days. Refill notification set for ${daysSupply - 2} days from now.';
  }

  /// Calculate exact days until medication runs out
  static int? calculateDaysUntilEmpty({
    required String quantity,
    required String instructions,
  }) {
    final quantityNumber = _extractQuantityNumber(quantity);
    final dailyDosage = _parseDailyDosage(instructions);
    
    if (quantityNumber == null || dailyDosage == null) return null;
    
    return (quantityNumber / dailyDosage).floor();
  }
}