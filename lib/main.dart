import 'package:flutter/material.dart';
import 'package:powersystemsacademy/screens/home_screen.dart';
import 'package:powersystemsacademy/screens/calculators_screen.dart';
import 'package:powersystemsacademy/screens/community_screen.dart';
import 'package:powersystemsacademy/screens/learning_resources_screen.dart';
import 'package:powersystemsacademy/screens/news_screen.dart';
import 'package:powersystemsacademy/screens/profile_screen.dart';
import 'package:powersystemsacademy/screens/settings_screen.dart';
import 'package:powersystemsacademy/screens/study_materials_screen.dart';
import 'package:powersystemsacademy/theme/app_theme.dart';
import 'package:powersystemsacademy/calculators/three_phase_power_calculator.dart';
import 'package:powersystemsacademy/calculators/power_factor_calculator.dart';
import 'package:powersystemsacademy/calculators/transformer_sizing_calculator.dart';
import 'package:powersystemsacademy/calculators/voltage_drop_calculator.dart';
import 'package:powersystemsacademy/calculators/short_circuit_calculator.dart'; // Import the new calculator
import 'package:powersystemsacademy/calculators/load_flow_calculator.dart';
import 'package:powersystemsacademy/calculators/motor_starting_calculator.dart';
import 'package:powersystemsacademy/calculators/protection_coordination_calculator.dart';
import 'package:powersystemsacademy/screens/power_formulas_screen.dart';

import 'package:powersystemsacademy/screens/pe_exam_prep_screen.dart';
import 'package:powersystemsacademy/screens/pe_exam_planner_screen.dart';
import 'package:powersystemsacademy/screens/practice_questions_screen.dart';
import 'package:powersystemsacademy/screens/nec_reference_screen.dart';


import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

// Theme provider to manage app theme throughout the app
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = AppTheme.primaryIndigo;
  Color _accentColor = AppTheme.accentAmber;

  ThemeProvider() {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;

  ThemeData get currentTheme => _isDarkMode
      ? AppTheme.darkTheme(primaryColor: _primaryColor, secondaryColor: _accentColor)
      : AppTheme.lightTheme(primaryColor: _primaryColor, secondaryColor: _accentColor);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _savePreferences();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _primaryColor = _getColorFromPrefs(prefs, 'primaryColor', AppTheme.primaryIndigo);
      _accentColor = _getColorFromPrefs(prefs, 'accentColor', AppTheme.accentAmber);
      notifyListeners();
    } catch (e) {
      // Fallback to default theme if loading fails
      _isDarkMode = false;
      _primaryColor = AppTheme.primaryIndigo;
      _accentColor = AppTheme.accentAmber;
      notifyListeners();
    }
  }

  Color _getColorFromPrefs(SharedPreferences prefs, String key, Color defaultColor) {
    try {
      final colorValue = prefs.getInt(key);
      return colorValue != null ? Color(colorValue) : defaultColor;
    } catch (e) {
      return defaultColor;
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkMode', _isDarkMode);
      prefs.setInt('primaryColor', _primaryColor.value);
      prefs.setInt('accentColor', _accentColor.value);
    } catch (e) {
      // Handle the error (e.g., log it or show a message)
      debugPrint('Failed to save preferences: $e');
    }
  }

  // Helper method to get theme name for display purposes
  String getThemeName() {
    String modeName = _isDarkMode ? 'Dark' : 'Light';
    
    if (_primaryColor == AppTheme.primaryIndigo) return '$modeName Blue';
    if (_primaryColor == AppTheme.primaryBlue) return '$modeName Light Blue';
    if (_primaryColor == AppTheme.primaryTeal) return '$modeName Teal';
    if (_primaryColor == AppTheme.primaryGreen) return '$modeName Green';
    if (_primaryColor == AppTheme.primaryPurple) return '$modeName Purple';
    
    return '$modeName Custom';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const PowerEngineeringPrepApp(),
    ),
  );
}

class PowerEngineeringPrepApp extends StatelessWidget {
  const PowerEngineeringPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'PE Power Prep',
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/study_materials': (context) => StudyMaterialsScreen(),
        '/calculators': (context) => CalculatorsScreen(),
        '/calculators/three_phase': (context) => ThreePhaseCalculatorScreen(),
        '/calculators/power_factor': (context) => PowerFactorCalculatorScreen(),
        '/calculators/voltage_drop': (context) => VoltageDropCalculatorScreen(),
        '/calculators/transformer_sizing': (context) => TransformerSizingCalculatorScreen(),
        '/calculators/short_circuit': (context) => ShortCircuitCalculatorScreen(), // Add route for the new calculator
        '/calculators/load_flow': (context) => LoadFlowCalculatorScreen(),
        '/calculators/motor_starting': (context) => MotorStartingCalculatorScreen(),
        '/calculators/protection_coordination': (context) => ProtectionCoordinationCalculatorScreen(),
        '/power_formulas': (context) => PowerFormulasScreen(),
        '/pe_exam_prep': (context) => PEExamPrepScreen(),
        '/pe_exam_planner': (context) => PEExamPlannerScreen(),
        '/practice_questions': (context) => PracticeQuestionsScreen(),
        '/nec_reference': (context) => NECReferenceScreen(),
        '/learning_resources': (context) => LearningResourcesScreen(),
        '/community': (context) => CommunityScreen(),
        '/news': (context) => NewsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}