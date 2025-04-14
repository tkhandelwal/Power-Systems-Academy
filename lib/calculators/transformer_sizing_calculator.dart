// lib/calculators/transformer_sizing_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class TransformerSizingCalculatorScreen extends StatefulWidget {
  const TransformerSizingCalculatorScreen({super.key});

  @override
  TransformerSizingCalculatorScreenState createState() => 
      TransformerSizingCalculatorScreenState();
}

class TransformerSizingCalculatorScreenState 
    extends State<TransformerSizingCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _loadKVAController = TextEditingController();
  final TextEditingController _powerFactorController = TextEditingController();
  final TextEditingController _primaryVoltageController = TextEditingController();
  final TextEditingController _secondaryVoltageController = TextEditingController();
  final TextEditingController _loadFactorController = TextEditingController(text: '0.8');
  final TextEditingController _ambientTemperatureController = TextEditingController(text: '40');
  
  // System type
  String _phaseType = 'three-phase'; // 'single-phase' or 'three-phase'
  String _connectionType = 'delta-wye'; // 'delta-wye', 'wye-wye', 'delta-delta'
  
  // Results
  double _requiredKVA = 0.0;
  double _primaryCurrent = 0.0;
  double _secondaryCurrent = 0.0;
  double _efficiency = 0.0;
  double _temperatureRise = 0.0;
  bool _hasCalculated = false;
  
  // Calculate transformer sizing
  void _calculateTransformerSizing() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double loadKVA = double.parse(_loadKVAController.text);
      double powerFactor = double.parse(_powerFactorController.text);
      double primaryVoltage = double.parse(_primaryVoltageController.text);
      double secondaryVoltage = double.parse(_secondaryVoltageController.text);
      double loadFactor = double.parse(_loadFactorController.text);
      double ambientTemperature = double.parse(_ambientTemperatureController.text);
      
      // Calculate required transformer kVA with safety factor (20% for future expansion)
      _requiredKVA = loadKVA / loadFactor * 1.2;
      
      // Calculate primary and secondary currents
      if (_phaseType == 'three-phase') {
        _primaryCurrent = (loadKVA * 1000) / (sqrt(3) * primaryVoltage * powerFactor);
        _secondaryCurrent = (loadKVA * 1000) / (sqrt(3) * secondaryVoltage * powerFactor);
      } else {
        // Single-phase calculation
        _primaryCurrent = (loadKVA * 1000) / (primaryVoltage * powerFactor);
        _secondaryCurrent = (loadKVA * 1000) / (secondaryVoltage * powerFactor);
      }
      
      // Estimate efficiency based on transformer size
      // This is a simplified approximation; actual efficiency depends on design
      if (_requiredKVA <= 25) {
        _efficiency = 0.95; // 95% for small transformers
      } else if (_requiredKVA <= 100) {
        _efficiency = 0.97; // 97% for medium transformers
      } else if (_requiredKVA <= 500) {
        _efficiency = 0.98; // 98% for large transformers
      } else {
        _efficiency = 0.99; // 99% for very large transformers
      }
      
      // Estimate temperature rise based on ambient temperature
      // Standard transformer temperature rise is 65°C at 40°C ambient
      double standardRise = 65.0;
      double standardAmbient = 40.0;
      
      // Adjust rise for different ambient temperatures
      // This is a simplified model; actual calculation would depend on detailed design factors
      if (ambientTemperature > standardAmbient) {
        // Higher ambient temperature reduces temperature rise capability
        _temperatureRise = standardRise - (ambientTemperature - standardAmbient) * 0.5;
      } else {
        // Lower ambient temperature allows higher temperature rise
        _temperatureRise = standardRise + (standardAmbient - ambientTemperature) * 0.25;
      }
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  @override
  void dispose() {
    _loadKVAController.dispose();
    _powerFactorController.dispose();
    _primaryVoltageController.dispose();
    _secondaryVoltageController.dispose();
    _loadFactorController.dispose();
    _ambientTemperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transformer Sizing Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System type selector
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Single-Phase'),
                              value: 'single-phase',
                              groupValue: _phaseType,
                              onChanged: (value) {
                                setState(() {
                                  _phaseType = value!;
                                  // Reset connection type for single-phase
                                  if (value == 'single-phase') {
                                    _connectionType = 'delta-wye';
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Three-Phase'),
                              value: 'three-phase',
                              groupValue: _phaseType,
                              onChanged: (value) {
                                setState(() {
                                  _phaseType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      // Only show connection type for three-phase
                      if (_phaseType == 'three-phase') ...[
                        SizedBox(height: 12),
                        Text(
                          'Connection Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _connectionType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'delta-wye',
                              child: Text('Delta-Wye (Δ-Y)'),
                            ),
                            DropdownMenuItem(
                              value: 'wye-wye',
                              child: Text('Wye-Wye (Y-Y)'),
                            ),
                            DropdownMenuItem(
                              value: 'delta-delta',
                              child: Text('Delta-Delta (Δ-Δ)'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _connectionType = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Load parameters
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Load Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _loadKVAController,
                        decoration: InputDecoration(
                          labelText: 'Load kVA',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.power),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the load kVA';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _powerFactorController,
                        decoration: InputDecoration(
                          labelText: 'Power Factor (0 to 1)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the power factor';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (number <= 0 || number > 1) {
                            return 'Power factor must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _loadFactorController,
                        decoration: InputDecoration(
                          labelText: 'Load Factor (0 to 1)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.trending_down),
                          helperText: 'Typical values: 0.6-0.8',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the load factor';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (number <= 0 || number > 1) {
                            return 'Load factor must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Voltage parameters
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voltage Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _primaryVoltageController,
                        decoration: InputDecoration(
                          labelText: 'Primary Voltage (V)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the primary voltage';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _secondaryVoltageController,
                        decoration: InputDecoration(
                          labelText: 'Secondary Voltage (V)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the secondary voltage';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _ambientTemperatureController,
                        decoration: InputDecoration(
                          labelText: 'Ambient Temperature (°C)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.thermostat),
                          helperText: 'Standard design is 40°C',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the ambient temperature';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateTransformerSizing,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Calculate Transformer Sizing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Results display
              if (_hasCalculated)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.electrical_services,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Transformer Sizing Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ResultItem(
                          label: 'Required Transformer Size:',
                          value: '${_requiredKVA.toStringAsFixed(2)} kVA',
                          icon: Icons.power_input,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Primary Current:',
                          value: '${_primaryCurrent.toStringAsFixed(2)} A',
                          icon: Icons.electric_bolt,
                          iconColor: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Secondary Current:',
                          value: '${_secondaryCurrent.toStringAsFixed(2)} A',
                          icon: Icons.electric_bolt,
                          iconColor: Colors.green,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Estimated Efficiency:',
                          value: '${(_efficiency * 100).toStringAsFixed(1)}%',
                          icon: Icons.eco,
                          iconColor: Colors.green,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Temperature Rise:',
                          value: '${_temperatureRise.toStringAsFixed(1)}°C',
                          icon: Icons.thermostat,
                          iconColor: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Standard transformer sizes: 15, 30, 45, 75, 112.5, 150, 225, 300, 500, 750, 1000, 1500, 2000, 2500 kVA',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Choose the next standard size above the calculated requirement',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Consider future expansion needs when selecting transformer size',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement save or export results
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Results saved to your device'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Icon(Icons.save_alt),
                          label: Text('Save Results'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(double.infinity, 44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              SizedBox(height: 24),
              
              // Educational content
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Transformer Sizing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Proper transformer sizing is critical for efficient and reliable power distribution. Considerations include:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Load growth and future expansion needs',
                        icon: Icons.trending_up,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Ambient temperature and environmental conditions',
                        icon: Icons.thermostat,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Efficiency and energy costs over transformer lifetime',
                        icon: Icons.eco,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Reliability requirements and redundancy needs',
                        icon: Icons.verified,
                        iconColor: Colors.purple,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show transformer learning resources
                              },
                              icon: Icon(Icons.book),
                              label: Text('Learn More'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const ResultItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BenefitItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const BenefitItem({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}