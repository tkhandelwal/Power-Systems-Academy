// lib/services/calculator_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage calculator usage history and data
class CalculatorService {
  // Singleton pattern
  static final CalculatorService _instance = CalculatorService._internal();
  factory CalculatorService() => _instance;
  CalculatorService._internal();
  
  // Key for storing recent calculators in shared preferences
  static const String _recentCalculatorsKey = 'recent_calculators';
  
  // Maximum number of recent calculators to store
  static const int _maxRecentCalculators = 5;
  
  // Key for storing saved calculation inputs
  static const String _savedCalculationsKey = 'saved_calculations';
  
  /// Get list of recently used calculators
  Future<List<Map<String, dynamic>>> getRecentCalculators() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = prefs.getStringList(_recentCalculatorsKey) ?? [];
      
      return recentJson
          .map((jsonStr) => Map<String, dynamic>.from(json.decode(jsonStr)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent calculators: $e');
      }
      return [];
    }
  }
  
  /// Add calculator to recent list
  Future<void> addToRecentCalculators(Map<String, dynamic> calculator) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing list
      List<String> recentJson = prefs.getStringList(_recentCalculatorsKey) ?? [];
      List<Map<String, dynamic>> recentCalculators = recentJson
          .map((jsonStr) => Map<String, dynamic>.from(json.decode(jsonStr)))
          .toList();
      
      // Remove if already exists
      recentCalculators.removeWhere((c) => c['title'] == calculator['title']);
      
      // Add to beginning
      recentCalculators.insert(0, calculator);
      
      // Limit size
      if (recentCalculators.length > _maxRecentCalculators) {
        recentCalculators = recentCalculators.sublist(0, _maxRecentCalculators);
      }
      
      // Convert back to JSON and save
      List<String> updatedJsonList = recentCalculators
          .map((calc) => json.encode(calc))
          .toList();
      
      await prefs.setStringList(_recentCalculatorsKey, updatedJsonList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving recent calculators: $e');
      }
    }
  }
  
  /// Save calculation inputs for later use
  Future<void> saveCalculation({
    required String calculatorType,
    required String name,
    required Map<String, dynamic> inputs,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing saved calculations
      final savedJson = prefs.getString(_savedCalculationsKey) ?? '{}';
      Map<String, dynamic> savedCalculations = json.decode(savedJson);
      
      // Get calculator-specific saved calculations
      List<Map<String, dynamic>> calculatorSaved = 
          savedCalculations[calculatorType] != null
              ? List<Map<String, dynamic>>.from(savedCalculations[calculatorType])
              : [];
      
      // Create new saved calculation
      Map<String, dynamic> savedCalc = {
        'name': name,
        'timestamp': DateTime.now().toIso8601String(),
        'inputs': inputs,
      };
      
      // Add to list
      calculatorSaved.add(savedCalc);
      
      // Update main map
      savedCalculations[calculatorType] = calculatorSaved;
      
      // Save back to preferences
      await prefs.setString(_savedCalculationsKey, json.encode(savedCalculations));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving calculation: $e');
      }
    }
  }
  
  /// Get saved calculations for a specific calculator
  Future<List<Map<String, dynamic>>> getSavedCalculations(String calculatorType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all saved calculations
      final savedJson = prefs.getString(_savedCalculationsKey) ?? '{}';
      Map<String, dynamic> savedCalculations = json.decode(savedJson);
      
      // Get calculator-specific saved calculations
      if (savedCalculations.containsKey(calculatorType)) {
        return List<Map<String, dynamic>>.from(savedCalculations[calculatorType]);
      }
      
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error loading saved calculations: $e');
      }
      return [];
    }
  }
  
  /// Delete a saved calculation
  Future<void> deleteSavedCalculation(String calculatorType, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all saved calculations
      final savedJson = prefs.getString(_savedCalculationsKey) ?? '{}';
      Map<String, dynamic> savedCalculations = json.decode(savedJson);
      
      // Get calculator-specific saved calculations
      if (savedCalculations.containsKey(calculatorType)) {
        List<Map<String, dynamic>> calculatorSaved =
            List<Map<String, dynamic>>.from(savedCalculations[calculatorType]);
        
        // Remove the specified calculation
        if (index >= 0 && index < calculatorSaved.length) {
          calculatorSaved.removeAt(index);
          
          // Update main map
          savedCalculations[calculatorType] = calculatorSaved;
          
          // Save back to preferences
          await prefs.setString(_savedCalculationsKey, json.encode(savedCalculations));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting saved calculation: $e');
      }
    }
  }
  
  /// Log calculator usage for analytics (future feature)
  Future<void> logCalculatorUsage(String calculatorType) async {
    // Implementation for usage analytics
    // This could be expanded in the future
    if (kDebugMode) {
      print('Calculator used: $calculatorType at ${DateTime.now()}');
    }
  }
}