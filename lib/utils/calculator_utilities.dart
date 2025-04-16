// lib/utils/calculator_utilities.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Utility class with helper methods for calculator functions
class CalculatorUtilities {
  // Private constructor to prevent instantiation
  CalculatorUtilities._();
  
  /// Convert from one unit to another
  static double convertUnits(double value, String fromUnit, String toUnit) {
    // Conversion factors for common units
    const Map<String, Map<String, double>> conversionFactors = {
      // Length units
      'm': {
        'mm': 1000.0,
        'cm': 100.0,
        'm': 1.0,
        'km': 0.001,
        'in': 39.3701,
        'ft': 3.28084,
        'yd': 1.09361,
        'mi': 0.000621371,
      },
      
      // Voltage units
      'V': {
        'mV': 1000.0,
        'V': 1.0,
        'kV': 0.001,
      },
      
      // Current units
      'A': {
        'mA': 1000.0,
        'A': 1.0,
        'kA': 0.001,
      },
      
      // Power units
      'W': {
        'W': 1.0,
        'kW': 0.001,
        'MW': 0.000001,
        'hp': 0.00134102,
        'VA': 1.0,      // Assuming power factor of 1
        'kVA': 0.001,   // Assuming power factor of 1
        'MVA': 0.000001, // Assuming power factor of 1
      },
      
      // Energy units
      'Wh': {
        'Wh': 1.0,
        'kWh': 0.001,
        'MWh': 0.000001,
        'J': 3600.0,
        'kJ': 3.6,
        'MJ': 0.0036,
      },
      
      // Impedance units
      'ohm': {
        'mohm': 1000.0,
        'ohm': 1.0,
        'kohm': 0.001,
      },
    };

    // Find the base unit for the fromUnit
    String? baseUnitFrom;
    for (var baseUnit in conversionFactors.keys) {
      if (conversionFactors[baseUnit]!.containsKey(fromUnit)) {
        baseUnitFrom = baseUnit;
        break;
      }
    }
    
    // Find the base unit for the toUnit
    String? baseUnitTo;
    for (var baseUnit in conversionFactors.keys) {
      if (conversionFactors[baseUnit]!.containsKey(toUnit)) {
        baseUnitTo = baseUnit;
        break;
      }
    }
    
    // If base units are different or not found, throw error
    if (baseUnitFrom == null || baseUnitTo == null || baseUnitFrom != baseUnitTo) {
      throw ArgumentError('Cannot convert between different types of units: $fromUnit to $toUnit');
    }
    
    // Convert from the original unit to the base unit, then to the target unit
    double valueInBaseUnit = value / conversionFactors[baseUnitFrom]![fromUnit]!;
    double convertedValue = valueInBaseUnit * conversionFactors[baseUnitTo]![toUnit]!;
    
    return convertedValue;
  }
  
  /// Round a value to a specified number of decimal places
  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }
  
  /// Format a number with appropriate units (e.g., convert 1000 W to 1 kW)
  static String formatWithUnits(double value, String unit) {
    // Unit prefixes and their corresponding factors
    const Map<String, double> prefixes = {
      'p': 1e-12, // pico
      'n': 1e-9,  // nano
      'μ': 1e-6,  // micro
      'm': 1e-3,  // milli
      '': 1.0,    // no prefix
      'k': 1e3,   // kilo
      'M': 1e6,   // mega
      'G': 1e9,   // giga
      'T': 1e12,  // tera
    };
    
    // Find base unit (without prefix)
    String baseUnit = unit;
    String prefix = '';
    
    for (var p in prefixes.keys) {
      if (p.isNotEmpty && unit.startsWith(p)) {
        prefix = p;
        baseUnit = unit.substring(p.length);
        break;
      }
    }
    
    // Normalize value to appropriate prefix
    double absValue = value.abs();
    String newPrefix = '';
    double normalizedValue = value;
    
    if (absValue == 0) {
      newPrefix = '';
    } else if (absValue < 1e-9) {
      newPrefix = 'p';
      normalizedValue = value / prefixes['p']!;
    } else if (absValue < 1e-6) {
      newPrefix = 'n';
      normalizedValue = value / prefixes['n']!;
    } else if (absValue < 1e-3) {
      newPrefix = 'μ';
      normalizedValue = value / prefixes['μ']!;
    } else if (absValue < 1) {
      newPrefix = 'm';
      normalizedValue = value / prefixes['m']!;
    } else if (absValue < 1e3) {
      newPrefix = '';
    } else if (absValue < 1e6) {
      newPrefix = 'k';
      normalizedValue = value / prefixes['k']!;
    } else if (absValue < 1e9) {
      newPrefix = 'M';
      normalizedValue = value / prefixes['M']!;
    } else if (absValue < 1e12) {
      newPrefix = 'G';
      normalizedValue = value / prefixes['G']!;
    } else {
      newPrefix = 'T';
      normalizedValue = value / prefixes['T']!;
    }
    
    // Round the normalized value to 4 significant digits
    if (normalizedValue.abs() >= 100) {
      normalizedValue = normalizedValue.roundToDouble();
    } else if (normalizedValue.abs() >= 10) {
      normalizedValue = (normalizedValue * 10).roundToDouble() / 10;
    } else if (normalizedValue.abs() >= 1) {
      normalizedValue = (normalizedValue * 100).roundToDouble() / 100;
    } else {
      normalizedValue = (normalizedValue * 1000).roundToDouble() / 1000;
    }
    
    return '$normalizedValue $newPrefix$baseUnit';
  }
  
  /// Check if a value is within acceptable engineering tolerance
  static bool isWithinTolerance(double value, double expectedValue, double tolerancePercent) {
    double tolerance = expectedValue * (tolerancePercent / 100);
    return (value - expectedValue).abs() <= tolerance;
  }
  
  /// Calculate impedance from resistance and reactance
  static double calculateImpedance(double resistance, double reactance) {
    return sqrt(resistance * resistance + reactance * reactance);
  }
  
  /// Calculate phase angle from resistance and reactance
  static double calculatePhaseAngle(double resistance, double reactance) {
    return atan2(reactance, resistance) * (180 / pi); // Convert to degrees
  }
  
  /// Calculate power factor from phase angle
  static double calculatePowerFactor(double phaseAngle) {
    // Convert angle from degrees to radians
    double angleInRadians = phaseAngle * (pi / 180);
    return cos(angleInRadians);
  }
  
  /// Calculate voltage drop in a conductor
  static double calculateVoltageDrop({
    required double current,
    required double resistance,
    required double reactance,
    required double powerFactor,
    required double length,
  }) {
    // Calculate phase angle
    double phaseAngle = acos(powerFactor);
    
    // Calculate voltage drop
    double voltageDrop = current * length * (resistance * cos(phaseAngle) + reactance * sin(phaseAngle));
    
    return voltageDrop;
  }
  
  /// Check if a number is within the valid range
  static bool isInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }
  
  /// Validate an input string as a number within range
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must not exceed $max';
    }
    
    return null; // Valid number
  }
  
  /// Generate a range of numbers with specified step
  static List<double> generateRange(double start, double end, double step) {
    List<double> range = [];
    for (double i = start; i <= end; i += step) {
      range.add(roundToDecimalPlaces(i, 4));
    }
    return range;
  }
  
  /// Convert between common power engineering units
  static double convertPowerEngineeringUnits(
    double value, 
    String fromUnit, 
    String toUnit,
  ) {
    // Define conversion factors for power engineering units
    const Map<String, Map<String, double>> conversionFactors = {
      // Power units
      'W': {
        'W': 1.0,
        'kW': 0.001,
        'MW': 0.000001,
        'VA': 1.0,
        'kVA': 0.001,
        'MVA': 0.000001,
        'VAR': 1.0,
        'kVAR': 0.001,
        'MVAR': 0.000001,
      },
      
      // Voltage units
      'V': {
        'V': 1.0,
        'kV': 0.001,
        'V/m': 1.0,
        'kV/m': 0.001,
      },
      
      // Current units
      'A': {
        'A': 1.0,
        'kA': 0.001,
        'A/m': 1.0,
      },
      
      // Per unit values
      'pu': {
        'pu': 1.0,
        '%': 100.0,
      },
      
      // Frequency units
      'Hz': {
        'Hz': 1.0,
        'kHz': 0.001,
        'MHz': 0.000001,
        'rad/s': 0.159155, // Conversion from Hz to rad/s (2π radians = 1 cycle)
      },
      
      // Impedance units
      'ohm': {
        'ohm': 1.0,
        'kohm': 0.001,
        'mohm': 1000.0,
        'ohm-m': 1.0, // Assuming 1 meter length
      },
      
      // Conductance units
      'S': {
        'S': 1.0,
        'mS': 1000.0,
        'μS': 1000000.0,
      },
      
      // Energy units
      'J': {
        'J': 1.0,
        'kJ': 0.001,
        'MJ': 0.000001,
        'Wh': 0.000277778,
        'kWh': 0.000000277778,
        'MWh': 0.000000000277778,
      },
    };
    
    // Find base unit category for fromUnit
    String? baseCategory;
    for (var category in conversionFactors.keys) {
      if (conversionFactors[category]!.containsKey(fromUnit)) {
        baseCategory = category;
        break;
      }
    }
    
    // Find base unit category for toUnit
    String? toCategory;
    for (var category in conversionFactors.keys) {
      if (conversionFactors[category]!.containsKey(toUnit)) {
        toCategory = category;
        break;
      }
    }
    
    // Check if units are compatible
    if (baseCategory == null || toCategory == null || baseCategory != toCategory) {
      throw ArgumentError('Cannot convert between incompatible units: $fromUnit to $toUnit');
    }
    
    // Perform conversion
    double baseValue = value / conversionFactors[baseCategory]![fromUnit]!;
    return baseValue * conversionFactors[toCategory]![toUnit]!;
  }
}