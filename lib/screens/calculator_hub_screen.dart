// lib/screens/calculator_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:powersystemsacademy/calculators/three_phase_power_calculator.dart';
import 'package:powersystemsacademy/calculators/power_factor_calculator.dart';
import 'package:powersystemsacademy/calculators/transformer_sizing_calculator.dart';
import 'package:powersystemsacademy/calculators/voltage_drop_calculator.dart';
import 'package:powersystemsacademy/calculators/short_circuit_calculator.dart';
import 'package:powersystemsacademy/calculators/load_flow_calculator.dart';
import 'package:powersystemsacademy/calculators/motor_starting_calculator.dart';
import 'package:powersystemsacademy/calculators/protection_coordination_calculator.dart';

class CalculatorHubScreen extends StatefulWidget {
  const CalculatorHubScreen({super.key});

  @override
  CalculatorHubScreenState createState() => CalculatorHubScreenState();
}

class CalculatorHubScreenState extends State<CalculatorHubScreen> {
  // Categories of calculators
  final List<Map<String, dynamic>> _calculatorCategories = [
    {
      'category': 'Power Analysis',
      'description': 'Core power system analysis calculators',
      'icon': Icons.power,
      'color': Colors.blue,
      'calculators': [
        {
          'title': 'Three-Phase Power',
          'description': 'Calculate three-phase power, voltage, and current relationships',
          'icon': Icons.electric_bolt,
          'screen': ThreePhaseCalculatorScreen(),
        },
        {
          'title': 'Power Factor Correction',
          'description': 'Calculate capacitor requirements for power factor improvement',
          'icon': Icons.speed,
          'screen': PowerFactorCalculatorScreen(),
        },
        {
          'title': 'Load Flow',
          'description': 'Analyze voltage profiles and power flows in networks',
          'icon': Icons.account_tree,
          'screen': LoadFlowCalculatorScreen(),
        },
        {
          'title': 'Short Circuit Analysis',
          'description': 'Calculate fault currents and interrupting requirements',
          'icon': Icons.flash_on,
          'screen': ShortCircuitCalculatorScreen(),
        },
      ],
    },
    {
      'category': 'Equipment Sizing',
      'description': 'Calculators for sizing and selecting equipment',
      'icon': Icons.architecture,
      'color': Colors.green,
      'calculators': [
        {
          'title': 'Transformer Sizing',
          'description': 'Determine appropriate transformer rating for loads',
          'icon': Icons.transform,
          'screen': TransformerSizingCalculatorScreen(),
        },
        {
          'title': 'Voltage Drop',
          'description': 'Calculate voltage drop in conductors and verify compliance',
          'icon': Icons.trending_down,
          'screen': VoltageDropCalculatorScreen(),
        },
      ],
    },
    {
      'category': 'Protection & Control',
      'description': 'Calculate protection settings and coordination',
      'icon': Icons.security,
      'color': Colors.orange,
      'calculators': [
        {
          'title': 'Protection Coordination',
          'description': 'Analyze and verify protective device coordination',
          'icon': Icons.timer,
          'screen': ProtectionCoordinationCalculatorScreen(),
        },
        {
          'title': 'Motor Starting',
          'description': 'Calculate voltage drop and starting requirements for motors',
          'icon': Icons.rotate_right,
          'screen': MotorStartingCalculatorScreen(),
        },
      ],
    },
  ];

  // Recently used calculators (will be populated dynamically)
  final List<Map<String, dynamic>> _recentCalculators = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Power Engineering Calculators'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showCalculatorInfo(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.calculate,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Engineering Calculators',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Tools for power system analysis',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'These calculators provide essential tools for power engineering analysis, helping you solve complex problems and prepare for the PE Power exam.',
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Each calculator includes guidance and educational content.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Recent Calculators Section
            if (_recentCalculators.isNotEmpty) ...[
              Text(
                'Recently Used',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentCalculators.length,
                  itemBuilder: (context, index) {
                    final calculator = _recentCalculators[index];
                    return SizedBox(
                      width: 180,
                      child: Card(
                        margin: EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => calculator['screen'],
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  calculator['icon'],
                                  size: 36,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  calculator['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
            ],
            
            // All Calculators by Category
            ...List.generate(_calculatorCategories.length, (categoryIndex) {
              final category = _calculatorCategories[categoryIndex];
              return _buildCategorySection(context, category);
            }),
            
            SizedBox(height: 16),
            
            // Exam-related reminders
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.amber.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, color: Colors.amber.shade800),
                        SizedBox(width: 8),
                        Text(
                          'PE Exam Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Know how to perform these calculations quickly and efficiently on your exam-approved calculator. Remember to verify your results with multiple approaches.',
                    ),
                    SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/pe_exam_prep');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade800,
                        side: BorderSide(color: Colors.amber.shade800),
                      ),
                      child: Text('Exam Preparation Tips'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySection(BuildContext context, Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['category'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    category['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: category['calculators'].length,
          itemBuilder: (context, index) {
            final calculator = category['calculators'][index];
            return _buildCalculatorCard(context, calculator);
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildCalculatorCard(BuildContext context, Map<String, dynamic> calculator) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Add to recent calculators
          _addToRecentCalculators(calculator);
          
          // Navigate to calculator screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => calculator['screen'],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                calculator['icon'],
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 12),
              Text(
                calculator['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Expanded(
                child: Text(
                  calculator['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _addToRecentCalculators(Map<String, dynamic> calculator) {
    setState(() {
      // Remove if already exists
      _recentCalculators.removeWhere((c) => c['title'] == calculator['title']);
      
      // Add to the beginning
      _recentCalculators.insert(0, calculator);
      
      // Limit to 5 recent calculators
      if (_recentCalculators.length > 5) {
        _recentCalculators.removeLast();
      }
    });
  }
  
  void _showCalculatorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Power Engineering Calculators'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'These calculators are designed to help power engineers solve complex problems and prepare for the PE Power exam.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Calculator Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildInfoPoint('Educational content with each calculator'),
              _buildInfoPoint('Formulas and methodology explanations'),
              _buildInfoPoint('Relevant code references where applicable'),
              _buildInfoPoint('Example problems and solutions'),
              SizedBox(height: 16),
              Text(
                'For comprehensive exam preparation, use these calculators alongside the study materials and practice questions in the app.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}