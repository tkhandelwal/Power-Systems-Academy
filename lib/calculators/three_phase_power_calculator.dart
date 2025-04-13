// lib/calculators/three_phase_power_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ThreePhaseCalculatorScreen extends StatefulWidget {
  const ThreePhaseCalculatorScreen({super.key});

  @override
  _ThreePhaseCalculatorScreenState createState() => _ThreePhaseCalculatorScreenState();
}

class _ThreePhaseCalculatorScreenState extends State<ThreePhaseCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Connection type
  String _connectionType = 'wye'; // 'wye' or 'delta'
  
  // Controllers for input fields
  final TextEditingController _voltageController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _powerFactorController = TextEditingController();
  
  // Results
  double _realPower = 0.0;      // P in watts
  double _reactivePower = 0.0;  // Q in VAR
  double _apparentPower = 0.0;  // S in VA
  
  // Calculate power values based on inputs
  void _calculatePower() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double voltage = double.parse(_voltageController.text);
      double current = double.parse(_currentController.text);
      double powerFactor = double.parse(_powerFactorController.text);
      
      // Ensure power factor is between 0 and 1
      powerFactor = powerFactor.clamp(0.0, 1.0);
      
      // Calculate powers
      double sqrt3 = sqrt(3);
      
      if (_connectionType == 'wye') {
        // For Wye (Y) connection:
        // Line-to-line voltage is √3 times line-to-neutral voltage
        double lineToLineVoltage = voltage * sqrt3;
        
        // Calculations
        _apparentPower = sqrt3 * lineToLineVoltage * current;
        _realPower = _apparentPower * powerFactor;
        _reactivePower = _apparentPower * sin(acos(powerFactor));
      } else {
        // For Delta (Δ) connection:
        // Calculations (voltage is already line-to-line)
        _apparentPower = sqrt3 * voltage * current;
        _realPower = _apparentPower * powerFactor;
        _reactivePower = _apparentPower * sin(acos(powerFactor));
      }
      
      // Update state to show results
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _voltageController.dispose();
    _currentController.dispose();
    _powerFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Three-Phase Power Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection type selector
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
                        'Connection Type',
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
                              title: Text('Wye (Y)'),
                              value: 'wye',
                              groupValue: _connectionType,
                              onChanged: (value) {
                                setState(() {
                                  _connectionType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Delta (Δ)'),
                              value: 'delta',
                              groupValue: _connectionType,
                              onChanged: (value) {
                                setState(() {
                                  _connectionType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _connectionType == 'wye'
                            ? 'Enter Line-to-Neutral voltage for Wye connection'
                            : 'Enter Line-to-Line voltage for Delta connection',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Input fields
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
                        'Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _voltageController,
                        decoration: InputDecoration(
                          labelText: _connectionType == 'wye'
                              ? 'Voltage (Line-to-Neutral) in Volts'
                              : 'Voltage (Line-to-Line) in Volts',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a voltage value';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _currentController,
                        decoration: InputDecoration(
                          labelText: 'Current (Line) in Amperes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.arrow_right_alt),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a current value';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
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
                            return 'Please enter a power factor';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (number < 0 || number > 1) {
                            return 'Power factor must be between 0 and 1';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculatePower,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Calculate',
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
              if (_realPower > 0)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        ResultRow(
                          label: 'Real Power (P)',
                          value: _realPower,
                          unit: 'W',
                          icon: Icons.power,
                          color: Colors.green,
                        ),
                        Divider(),
                        ResultRow(
                          label: 'Reactive Power (Q)',
                          value: _reactivePower,
                          unit: 'VAR',
                          icon: Icons.power_input,
                          color: Colors.blue,
                        ),
                        Divider(),
                        ResultRow(
                          label: 'Apparent Power (S)',
                          value: _apparentPower,
                          unit: 'VA',
                          icon: Icons.show_chart,
                          color: Colors.purple,
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Power Triangle',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'The power triangle represents the relationship between:',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '• Real Power (P): Actual power consumed/used',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Reactive Power (Q): Power oscillating between source and load',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Apparent Power (S): Vector sum of P and Q',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
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

class ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const ResultRow({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayValue = value.toStringAsFixed(2);
    
    // Format large numbers for better readability
    if (value >= 1000000) {
      displayValue = (value / 1000000).toStringAsFixed(2) + ' M';
    } else if (value >= 1000) {
      displayValue = (value / 1000).toStringAsFixed(2) + ' k';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Spacer(),
          Text(
            '$displayValue $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}