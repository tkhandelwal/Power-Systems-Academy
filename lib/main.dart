import 'package:flutter/material.dart';
import 'package:powersystemsacademy/screens/home_screen.dart';
import 'package:powersystemsacademy/screens/calculators_screen.dart';
import 'package:powersystemsacademy/screens/community_screen.dart';
import 'package:powersystemsacademy/screens/learning_resources_screen.dart';
import 'package:powersystemsacademy/screens/news_screen.dart';
import 'package:powersystemsacademy/screens/profile_screen.dart';
import 'package:powersystemsacademy/screens/settings_screen.dart';
import 'package:powersystemsacademy/screens/study_materials_screen.dart';

void main() {
  runApp(PowerEngineeringPrepApp());
}

class PowerEngineeringPrepApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PE Power Prep',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        secondaryHeaderColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/study_materials': (context) => StudyMaterialsScreen(),
        '/calculators': (context) => CalculatorsScreen(),
        '/learning_resources': (context) => LearningResourcesScreen(),
        '/community': (context) => CommunityScreen(),
        '/news': (context) => NewsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}