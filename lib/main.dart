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
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _primaryColor = Color(prefs.getInt('primaryColor') ?? AppTheme.primaryIndigo.hashCode);
    _accentColor = Color(prefs.getInt('accentColor') ?? AppTheme.accentAmber.hashCode);
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setInt('primaryColor', _primaryColor.hashCode);
    prefs.setInt('accentColor', _accentColor.hashCode);
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: PowerEngineeringPrepApp(),
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
        '/learning_resources': (context) => LearningResourcesScreen(),
        '/community': (context) => CommunityScreen(),
        '/news': (context) => NewsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}