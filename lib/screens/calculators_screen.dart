import 'package:flutter/material.dart';

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
              'Three-Phase Power',
              'Power Factor Correction',
              'Transformer Sizing',
              'Voltage Drop',
              'Fault Current Analysis',
            ],
            onCategoryTap: () {
              // Navigate to power systems calculators
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'Electrical',
            description: 'Electrical system and component calculations',
            iconData: Icons.electrical_services,
            calculators: [
              'Conductor Sizing',
              'Conduit Fill',
              'Circuit Breaker Coordination',
              'Motor Starting',
              'Short Circuit',
            ],
            onCategoryTap: () {
              // Navigate to electrical calculators
            },
          ),
          SizedBox(height: 16),
          CalculatorCategoryCard(
            title: 'HVAC',
            description: 'Thermal and HVAC system calculations',
            iconData: Icons.ac_unit,
            calculators: [
              'Heat Load',
              'Psychrometrics',
              'Duct Sizing',
              'Pump Sizing',
              'Cooling Tower Efficiency',
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
              'Pipe Sizing',
              'Flow Rate',
              'Head Loss',
              'Pump Power',
              'Valve Sizing',
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
              'Present Worth',
              'Rate of Return',
              'Life Cycle Cost',
              'Payback Period',
              'Benefit-Cost Ratio',
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
  final List<String> calculators;
  final VoidCallback onCategoryTap;

  const CalculatorCategoryCard({
    super.key, // Use super.key instead of Key? key
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
                    backgroundColor: Theme.of(context).primaryColor.withAlpha(51), // 0.2 * 255 = 51
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
                  Icon(Icons.chevron_right),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: calculators.map((calculator) {
                  return Chip(
                    label: Text(calculator),
                    backgroundColor: Colors.grey[200],
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