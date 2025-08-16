// lib/utils/medication_refill_calculator.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MedicationRefillCalculator {
  /// Enhanced calculation using OpenAI for intelligent instruction parsing
  static Future<DateTime?> calculateRefillNotificationDateWithAI({
    required String quantity,
    required String instructions,
    DateTime? startDate,
  }) async {
    try {
      // First try AI-powered calculation
      final aiResult = await _calculateWithOpenAI(quantity, instructions);
      if (aiResult != null) {
        return _calculateDateFromAIResult(aiResult, startDate);
      }
      
      // Fallback to manual calculation if AI fails
      print('AI calculation failed, falling back to manual parsing');
      return calculateRefillNotificationDate(
        quantity: quantity,
        instructions: instructions,
        startDate: startDate,
      );
    } catch (e) {
      print('Error in AI calculation: $e');
      // Always fallback to manual calculation
      return calculateRefillNotificationDate(
        quantity: quantity,
        instructions: instructions,
        startDate: startDate,
      );
    }
  }

  /// Use OpenAI to intelligently parse medication instructions
  static Future<Map<String, dynamic>?> _calculateWithOpenAI(
    String quantity,
    String instructions,
  ) async {
    try {
      final String? apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              "role": "system",
              "content": """You are a medication dosage calculator. Analyze medication quantity and instructions to calculate how many days the medication will last.

Rules:
1. Extract the numeric quantity from the quantity string
2. Parse the daily dosage from instructions (tablets/pills/capsules per day)
3. Calculate days supply = quantity ÷ daily_dosage
4. Return ONLY a JSON object with no additional text

Return format:
{
  "quantity_number": <number>,
  "daily_dosage": <number>, 
  "days_supply": <number>,
  "calculation_confidence": <"high"|"medium"|"low">,
  "explanation": "<brief explanation>"
}

Examples:
- "30 tablets" + "take 1 tablet twice daily" = {"quantity_number": 30, "daily_dosage": 2, "days_supply": 15, "calculation_confidence": "high", "explanation": "30 tablets ÷ 2 per day = 15 days"}
- "20 capsules" + "take 2 capsules every 8 hours" = {"quantity_number": 20, "daily_dosage": 6, "days_supply": 3, "calculation_confidence": "high", "explanation": "20 capsules ÷ 6 per day (every 8 hours = 3 times daily, 2 each) = 3 days"}"""
            },
            {
              "role": "user",
              "content": "Calculate refill timing for:\nQuantity: $quantity\nInstructions: $instructions"
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final gptResponse = data['choices'][0]['message']['content'].toString().trim();
        
        print('GPT Refill Response: $gptResponse');
        
        // Parse JSON response
        final aiResult = jsonDecode(gptResponse);
        return aiResult;
      } else {
        print('OpenAI API error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling OpenAI for refill calculation: $e');
      return null;
    }
  }

  /// Calculate notification date from AI result
  static DateTime? _calculateDateFromAIResult(
    Map<String, dynamic> aiResult,
    DateTime? startDate,
  ) {
    try {
      final daysSupply = aiResult['days_supply'] as int?;
      if (daysSupply == null) return null;

      // Set notification 2 days before running out
      final bufferDays = 2;
      final notificationDays = daysSupply - bufferDays;
      
      // If medication runs out too quickly, notify immediately
      if (notificationDays <= 0) {
        return DateTime.now().add(Duration(hours: 1));
      }
      
      final medicationStartDate = startDate ?? DateTime.now();
      return medicationStartDate.add(Duration(days: notificationDays));
    } catch (e) {
      print('Error processing AI result: $e');
      return null;
    }
  }

  /// Calculate when to send refill notification based on quantity and instructions
  /// Returns notification date (2 days before medication runs out)
  /// FALLBACK METHOD - Used when AI calculation fails
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

  /// Get AI-powered calculation description
  static Future<String> getAICalculationDescription({
    required String quantity,
    required String instructions,
  }) async {
    try {
      final aiResult = await _calculateWithOpenAI(quantity, instructions);
      if (aiResult != null) {
        final confidence = aiResult['calculation_confidence'] ?? 'unknown';
        final explanation = aiResult['explanation'] ?? 'No explanation provided';
        final daysSupply = aiResult['days_supply'] ?? 0;
        return 'AI Analysis ($confidence confidence): $explanation. Refill notification set for ${daysSupply - 2} days from now.';
      }
      
      // Fallback to manual description
      return getCalculationDescription(
        quantity: quantity,
        instructions: instructions,
      );
    } catch (e) {
      return 'Error in AI calculation: ${e.toString()}';
    }
  }

  /// Get a human-readable description of the calculation (FALLBACK METHOD)
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
    return 'Manual Analysis: With $quantity and taking $dailyDosage per day, medication will last $daysSupply days. Refill notification set for ${daysSupply - 2} days from now.';
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