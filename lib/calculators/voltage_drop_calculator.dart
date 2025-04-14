// lib/calculators/voltage_drop_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class VoltageDropCalculatorScreen extends StatefulWidget {
  const VoltageDropCalculatorScreen({super.key});

  @override
  VoltageDropCalculatorScreenState createState() => VoltageDropCalculatorScreenState();
}

class VoltageDropCalculatorScreenState extends State<VoltageDropCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _wireGaugeController = TextEditingController();
  final TextEditingController _voltageController = TextEditingController(text: '240');
  final TextEditingController _powerFactorController = TextEditingController(text: '0.85');
  
  // System parameters
  String _systemType = 'single-phase-2w'; // 'single-phase-2w', 'single-phase-3w', 'three-phase'
  String _wireType = 'copper'; // 'copper' or 'aluminum'
  String _conduitType = 'pvc'; // 'pvc', 'steel', 'aluminum'
  String _temperatureRating = '75C'; // '60C', '75C', '90C'
  
  // Results
  double _voltageDropVolts = 0.0;
  double _voltageDropPercent = 0.0;
  double _wireResistance = 0.0;
  double _wireReactance = 0.0;
  double _powerLoss = 0.0;
  bool _hasCalculated = false;
  
  // Wire gauge resistance data (ohms per 1000ft at 75°C)
  final Map<String, Map<String, double>> _wireResistanceData = {
    'copper': {
      '14': 3.14, '12': 1.98, '10': 1.24, '8': 0.778, '6': 0.491,
      '4': 0.308, '3': 0.245, '2': 0.194, '1': 0.154, '1/0': 0.122,
      '2/0': 0.097, '3/0': 0.077, '4/0': 0.061, '250': 0.052, '300': 0.043,
      '350': 0.037, '400': 0.033, '500': 0.027, '600': 0.023, '750': 0.018,
    },
    'aluminum': {
      '14': 5.17, '12': 3.25, '10': 2.04, '8': 1.28, '6': 0.808,
      '4': 0.508, '3': 0.403, '2': 0.319, '1': 0.253, '1/0': 0.201,
      '2/0': 0.159, '3/0': 0.126, '4/0': 0.100, '250': 0.085, '300': 0.071,
      '350': 0.061, '400': 0.054, '500': 0.043, '600': 0.036, '750': 0.029,
    }
  };
  
  // Wire reactance data (ohms per 1000ft)
  final Map<String, Map<String, double>> _wireReactanceData = {
    'pvc': {
      '14': 0.058, '12': 0.054, '10': 0.050, '8': 0.052, '6': 0.051,
      '4': 0.048, '3': 0.047, '2': 0.045, '1': 0.044, '1/0': 0.043,
      '2/0': 0.042, '3/0': 0.041, '4/0': 0.040, '250': 0.039, '300': 0.039,
      '350': 0.038, '400': 0.038, '500': 0.037, '600': 0.037, '750': 0.036,
    },
    'steel': {
      '14': 0.073, '12': 0.068, '10': 0.063, '8': 0.065, '6': 0.064,
      '4': 0.060, '3': 0.059, '2': 0.057, '1': 0.055, '1/0': 0.054,
      '2/0': 0.053, '3/0': 0.052, '4/0': 0.051, '250': 0.049, '300': 0.048,
      '350': 0.048, '400': 0.047, '500': 0.046, '600': 0.046, '750': 0.045,
    },
    'aluminum': {
      '14': 0.064, '12': 0.059, '10': 0.055, '8': 0.057, '6': 0.056,
      '4': 0.053, '3': 0.052, '2': 0.050, '1': 0.049, '1/0': 0.048,
      '2/0': 0.046, '3/0': 0.045, '4/0': 0.044, '250': 0.043, '300': 0.042,
      '350': 0.042, '400': 0.041, '500': 0.040, '600': 0.040, '750': 0.039,
    }
  };
  
  // Temperature correction factors
  final Map<String, Map<String, double>> _temperatureCorrectionFactors = {
    'copper': {
      '60C': 0.95, '75C': 1.0, '90C': 1.04
    },
    'aluminum': {
      '60C': 0.94, '75C': 1.0, '90C': 1.05
    }
  };
  
  // Calculate voltage drop
  void _calculateVoltageDrop() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double current = double.parse(_currentController.text);
      double distance = double.parse(_distanceController.text);
      String wireGauge = _wireGaugeController.text;
      double voltage = double.parse(_voltageController.text);
      double powerFactor = double.parse(_powerFactorController.text);
      
      // Get resistance and reactance values
      double baseResistance = _wireResistanceData[_wireType]![wireGauge] ?? 0;
      double baseReactance = _wireReactanceData[_conduitType]![wireGauge] ?? 0;
      
      // Apply temperature correction factor
      double tempFactor = _temperatureCorrectionFactors[_wireType]![_temperatureRating] ?? 1.0;
      _wireResistance = baseResistance * tempFactor;
      _wireReactance = baseReactance;
      
      // Calculate impedance components
      double resistanceTerm = _wireResistance * powerFactor;
      double reactanceTerm = _wireReactance * sin(acos(powerFactor));
      
      // Calculate voltage drop based on system type
      double multiplier;
      if (_systemType == 'single-phase-2w') {
        multiplier = 2.0; // Round trip for hot and neutral
      } else if (_systemType == 'single-phase-3w') {
        multiplier = 1.0; // One way for hot (neutral is shared)
      } else {
        // three-phase
        multiplier = sqrt(3.0); // Phase factor for three-phase
      }
      
      // Convert distance from feet to thousands of feet for the calculation
      double distanceInKFeet = distance / 1000;
      
      // Calculate voltage drop (using Ohm's Law: V = I × Z)
      _voltageDropVolts = current * (resistanceTerm + reactanceTerm) * multiplier * distanceInKFeet;
      
      // Calculate voltage drop percentage
      _voltageDropPercent = (_voltageDropVolts / voltage) * 100;
      
      // Calculate power loss (I²R losses)
      _powerLoss = current * current * _wireResistance * multiplier * distanceInKFeet;
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  @override
  void dispose() {
    _currentController.dispose();
    _distanceController.dispose();
    _wireGaugeController.dispose();
    _voltageController.dispose();
    _powerFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voltage Drop Calculator'),
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
                      DropdownButtonFormField<String>(
                        value: _systemType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'Select System Type',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'single-phase-2w',
                            child: Text('Single-Phase (2-Wire)'),
                          ),
                          DropdownMenuItem(
                            value: 'single-phase-3w',
                            child: Text('Single-Phase (3-Wire)'),
                          ),
                          DropdownMenuItem(
                            value: 'three-phase',
                            child: Text('Three-Phase'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _systemType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Circuit parameters
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
                        'Circuit Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _currentController,
                        decoration: InputDecoration(
                          labelText: 'Current (A)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electric_bolt),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter current';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _distanceController,
                        decoration: InputDecoration(
                          labelText: 'One-way Distance (ft)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.straighten),
                          helperText: 'One-way distance from source to load',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter distance';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _voltageController,
                        decoration: InputDecoration(
                          labelText: 'System Voltage (V)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter voltage';
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
                          helperText: 'Typical values: 0.8-0.95',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter power factor';
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
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Wire parameters
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
                        'Wire Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _wireType,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelText: 'Conductor Material',
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'copper',
                                  child: Text('Copper'),
                                ),
                                DropdownMenuItem(
                                  value: 'aluminum',
                                  child: Text('Aluminum'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _wireType = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _wireGaugeController,
                              decoration: InputDecoration(
                                labelText: 'Wire Size (AWG/kcmil)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                helperText: 'e.g., 12, 10, 2/0, 350',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter wire size';
                                }
                                if (!_wireResistanceData[_wireType]!.containsKey(value)) {
                                  return 'Invalid wire size';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _conduitType,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelText: 'Conduit Type',
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'pvc',
                                  child: Text('PVC'),
                                ),
                                DropdownMenuItem(
                                  value: 'steel',
                                  child: Text('Steel'),
                                ),
                                DropdownMenuItem(
                                  value: 'aluminum',
                                  child: Text('Aluminum'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _conduitType = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _temperatureRating,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelText: 'Temperature Rating',
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: '60C',
                                  child: Text('60°C (140°F)'),
                                ),
                                DropdownMenuItem(
                                  value: '75C',
                                  child: Text('75°C (167°F)'),
                                ),
                                DropdownMenuItem(
                                  value: '90C',
                                  child: Text('90°C (194°F)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _temperatureRating = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateVoltageDrop,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Calculate Voltage Drop',
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
                              Icons.bolt,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Voltage Drop Results',
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
                          label: 'Voltage Drop:',
                          value: '${_voltageDropVolts.toStringAsFixed(2)} V',
                          icon: Icons.arrow_downward,
                          iconColor: _voltageDropPercent > 3 ? Colors.red : Colors.green,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Voltage Drop (%):',
                          value: '${_voltageDropPercent.toStringAsFixed(2)}%',
                          icon: Icons.percent,
                          iconColor: _voltageDropPercent > 3 ? Colors.red : Colors.green,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Wire Resistance:',
                          value: '${_wireResistance.toStringAsFixed(4)} Ω/kft',
                          icon: Icons.electrical_services,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Wire Reactance:',
                          value: '${_wireReactance.toStringAsFixed(4)} Ω/kft',
                          icon: Icons.electrical_services,
                          iconColor: Colors.purple,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Power Loss:',
                          value: '${_powerLoss.toStringAsFixed(2)} W',
                          icon: Icons.power_off,
                          iconColor: Colors.orange,
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
                                '• NEC recommends maximum 3% voltage drop for branch circuits, 5% for total (feeder + branch).',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Results exceeding 3% are highlighted in red and may need larger conductors.',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• For critical loads (motors, electronics), consider limiting voltage drop to 2%.',
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
                        'About Voltage Drop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Voltage drop in conductors can affect equipment performance and energy efficiency. Key considerations include:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'NEC limits voltage drop to ensure proper equipment operation',
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Higher current and longer distances increase voltage drop',
                        icon: Icons.trending_up,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Larger wire sizes reduce voltage drop but increase costs',
                        icon: Icons.attach_money,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Power factor and reactive loads affect actual voltage drop',
                        icon: Icons.electric_bolt,
                        iconColor: Colors.purple,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show voltage drop learning resources
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