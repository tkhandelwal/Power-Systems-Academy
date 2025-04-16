// lib/providers/calculator_provider.dart
import 'package:flutter/material.dart';
import 'package:powersystemsacademy/services/calculator_service.dart';
import 'package:powersystemsacademy/calculators/power_triangle_calculator.dart';
import 'package:powersystemsacademy/screens/calculator_hub_screen.dart';

/// A provider class to manage calculator-related state across the app
class CalculatorProvider extends ChangeNotifier {
  final CalculatorService _calculatorService = CalculatorService();
  
  // List of available calculators (for quick reference)
  final List<Map<String, dynamic>> _availableCalculators = [
    {
      'name': 'Power Triangle',
      'description': 'Calculate relationships between active, reactive, and apparent power',
      'icon': Icons.show_chart,
      'route': '/calculators/power_triangle',
      'screen': PowerTriangleCalculatorScreen(),
      'type': 'power_triangle',
      'category': 'Power Analysis',
    },
    // Add other calculators here as they are implemented
  ];
  
  // Recently used calculators
  List<Map<String, dynamic>> _recentCalculators = [];
  
  // Getters
  List<Map<String, dynamic>> get availableCalculators => _availableCalculators;
  List<Map<String, dynamic>> get recentCalculators => _recentCalculators;
  
  // Constructor
  CalculatorProvider() {
    _loadRecentCalculators();
  }
  
  // Load recently used calculators from storage
  Future<void> _loadRecentCalculators() async {
    _recentCalculators = await _calculatorService.getRecentCalculators();
    notifyListeners();
  }
  
  // Add calculator to recent list
  Future<void> addToRecentCalculators(String calculatorType) async {
    // Find calculator in available calculators
    final calculator = _availableCalculators.firstWhere(
      (calc) => calc['type'] == calculatorType,
      orElse: () => <String, dynamic>{},
    );
    
    if (calculator.isNotEmpty) {
      // Add to recent calculators
      await _calculatorService.addToRecentCalculators(calculator);
      
      // Reload recent calculators
      await _loadRecentCalculators();
    }
  }
  
  // Log calculator usage for analytics
  Future<void> logCalculatorUsage(String calculatorType) async {
    await _calculatorService.logCalculatorUsage(calculatorType);
    
    // Also add to recent calculators
    await addToRecentCalculators(calculatorType);
  }
  
  // Get calculator by type
  Map<String, dynamic>? getCalculatorByType(String calculatorType) {
    try {
      return _availableCalculators.firstWhere(
        (calc) => calc['type'] == calculatorType,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Get all calculators by category
  List<Map<String, dynamic>> getCalculatorsByCategory(String category) {
    return _availableCalculators.where(
      (calc) => calc['category'] == category,
    ).toList();
  }
  
  // Navigation methods
  void navigateToCalculator(BuildContext context, String calculatorType) {
    // Find calculator
    final calculator = getCalculatorByType(calculatorType);
    
    if (calculator != null) {
      // Log usage
      logCalculatorUsage(calculatorType);
      
      // Navigate to calculator
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => calculator['screen'],
        ),
      );
    } else {
      // Calculator not found, navigate to calculator hub
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CalculatorHubScreen(),
        ),
      );
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculator not found'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  // Register routes for all calculators
  Map<String, WidgetBuilder> getCalculatorRoutes() {
    Map<String, WidgetBuilder> routes = {};
    
    for (var calculator in _availableCalculators) {
      routes[calculator['route']] = (context) => calculator['screen'];
    }
    
    return routes;
  }
}