// lib/screens/calculators_screen.dart
import 'package:flutter/material.dart';
import 'package:powersystemsacademy/calculators/three_phase_power_calculator.dart';
import 'package:powersystemsacademy/calculators/power_factor_calculator.dart';
import 'package:powersystemsacademy/calculators/transformer_sizing_calculator.dart';
import 'package:powersystemsacademy/calculators/voltage_drop_calculator.dart';
import 'package:powersystemsacademy/calculators/short_circuit_calculator.dart'; // Import the new calculator
import 'package:powersystemsacademy/calculators/load_flow_calculator.dart';
import 'package:powersystemsacademy/calculators/motor_starting_calculator.dart';
import 'package:powersystemsacademy/calculators/protection_coordination_calculator.dart';


// Updated CalculatorsScreen to avoid deprecated color methods
class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Power Engineering Calculators'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          CalculatorCategoryCard(
            title: 'Power Systems',
            description: 'Calculate power, voltage, current and more',
            iconData: Icons.flash_on,
            calculators: [
              {'name': 'Three-Phase Power', 'implemented': true},
              {'name': 'Power Factor Correction', 'implemented': true},
              {'name': 'Transformer Sizing', 'implemented': true},
              {'name': 'Voltage Drop', 'implemented': true},
              {'name': 'Short Circuit Analysis', 'implemented': true},
              {'name': 'Load Flow Analysis', 'implemented': true}, // Add this new line

            ],
            onCategoryTap: () {
              // Navigate to power systems calculators list
              // This is now redundant as we're showing the list directly
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'Electrical',
            description: 'Electrical system and component calculations',
            iconData: Icons.electrical_services,
            calculators: [
              {'name': 'Conductor Sizing', 'implemented': false},
              {'name': 'Conduit Fill', 'implemented': false},
              {'name': 'Circuit Breaker Coordination', 'implemented': true},
              {'name': 'Motor Starting', 'implemented': true},
              {'name': 'Short Circuit', 'implemented': false},
            ],
            onCategoryTap: () {
              // Navigate to electrical calculators list
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'HVAC',
            description: 'Thermal and HVAC system calculations',
            iconData: Icons.ac_unit,
            calculators: [
              {'name': 'Heat Load', 'implemented': false},
              {'name': 'Psychrometrics', 'implemented': false},
              {'name': 'Duct Sizing', 'implemented': false},
              {'name': 'Pump Sizing', 'implemented': false},
              {'name': 'Cooling Tower Efficiency', 'implemented': false},
            ],
            onCategoryTap: () {
              // Navigate to HVAC calculators
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'Fluid Dynamics',
            description: 'Calculate flow rates, pressure drops and more',
            iconData: Icons.waves,
            calculators: [
              {'name': 'Pipe Sizing', 'implemented': false},
              {'name': 'Flow Rate', 'implemented': false},
              {'name': 'Head Loss', 'implemented': false},
              {'name': 'Pump Power', 'implemented': false},
              {'name': 'Valve Sizing', 'implemented': false},
            ],
            onCategoryTap: () {
              // Navigate to fluid dynamics calculators
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'Economics',
            description: 'Economic analysis for power projects',
            iconData: Icons.money,
            calculators: [
              {'name': 'Present Worth', 'implemented': false},
              {'name': 'Rate of Return', 'implemented': false},
              {'name': 'Life Cycle Cost', 'implemented': false},
              {'name': 'Payback Period', 'implemented': false},
              {'name': 'Benefit-Cost Ratio', 'implemented': false},
            ],
            onCategoryTap: () {
              // Navigate to economics calculators
            },
          ),
        ],
      ),
    );
  }
}

class CalculatorCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final List<Map<String, dynamic>> calculators;
  final VoidCallback onCategoryTap;

  const CalculatorCategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.calculators,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onCategoryTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100, // Light primary color
                    child: Icon(
                      iconData,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: calculators.map((calculator) {
                  return ActionChip(
                    label: Text(calculator['name']),
                    backgroundColor: calculator['implemented'] 
                        ? Colors.green.shade100  // Light green without using opacity
                        : Colors.grey[200],
                    avatar: calculator['implemented']
                        ? Icon(Icons.check_circle, size: 16, color: Colors.green)
                        : null,
                    onPressed: () {
                      // Navigate to the specific calculator when chip is tapped
                      if (calculator['name'] == 'Three-Phase Power' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThreePhaseCalculatorScreen(),
                          ),
                        );
                      } else if (calculator['name'] == 'Power Factor Correction' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PowerFactorCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Transformer Sizing' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransformerSizingCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Voltage Drop' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoltageDropCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Short Circuit Analysis' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShortCircuitCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Load Flow Analysis' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadFlowCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Motor Starting' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MotorStartingCalculatorScreen(),
                          ),
                        );
                        } else if (calculator['name'] == 'Circuit Breaker Coordination' && calculator['implemented']) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProtectionCoordinationCalculatorScreen(),
                          ),
                        );
                          } else if (!calculator['implemented']) {
                        // Show coming soon snackbar for unimplemented calculators
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${calculator['name']} calculator coming soon!'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}