// lib/calculators/motor_starting_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class MotorStartingCalculatorScreen extends StatefulWidget {
  const MotorStartingCalculatorScreen({super.key});

  @override
  MotorStartingCalculatorScreenState createState() => MotorStartingCalculatorScreenState();
}

class MotorStartingCalculatorScreenState extends State<MotorStartingCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _motorRatingController = TextEditingController();
  final TextEditingController _powerFactorController = TextEditingController(text: '0.8');
  final TextEditingController _efficiencyController = TextEditingController(text: '0.9');
  final TextEditingController _voltageController = TextEditingController();
  final TextEditingController _startingFactorController = TextEditingController(text: '6.0');
  final TextEditingController _systemImpedanceController = TextEditingController();
  final TextEditingController _transformerRatingController = TextEditingController();
  final TextEditingController _transformerImpedanceController = TextEditingController(text: '5.5');
  
  // Motor type and starting method
  String _motorType = 'induction'; // 'induction' or 'synchronous'
  String _startingMethod = 'direct'; // 'direct', 'star-delta', 'autotransformer', 'soft-starter', 'vfd'
  
  // Results
  double _fullLoadCurrent = 0.0;
  double _startingCurrent = 0.0;
  double _voltageDrop = 0.0;
  double _busFaultLevel = 0.0;
  double _motorStartingTorque = 0.0;
  bool _hasCalculated = false;
  
  // Calculate motor starting values
  void _calculateMotorStarting() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double motorRating = double.parse(_motorRatingController.text); // in kW
      double powerFactor = double.parse(_powerFactorController.text);
      double efficiency = double.parse(_efficiencyController.text);
      double voltage = double.parse(_voltageController.text); // in V
      double startingFactor = double.parse(_startingFactorController.text);
      double systemImpedance = double.parse(_systemImpedanceController.text); // in %
      double transformerRating = double.parse(_transformerRatingController.text); // in kVA
      double transformerImpedance = double.parse(_transformerImpedanceController.text); // in %
      
      // Calculate full load current (in A)
      if (_motorType == 'induction') {
        _fullLoadCurrent = (motorRating * 1000) / (sqrt(3) * voltage * powerFactor * efficiency);
      } else { // synchronous
        _fullLoadCurrent = (motorRating * 1000) / (sqrt(3) * voltage * efficiency);
      }
      
      // Calculate starting current based on starting method
      double startingCurrentFactor;
      switch (_startingMethod) {
        case 'direct':
          startingCurrentFactor = startingFactor;
          break;
        case 'star-delta':
          startingCurrentFactor = startingFactor / 3.0;
          break;
        case 'autotransformer':
          startingCurrentFactor = startingFactor * 0.4; // Assuming 40% tap
          break;
        case 'soft-starter':
          startingCurrentFactor = startingFactor * 0.3; // Typical soft starter limitation
          break;
        case 'vfd':
          startingCurrentFactor = 1.5; // Typical VFD current limitation
          break;
        default:
          startingCurrentFactor = startingFactor;
      }
      
      _startingCurrent = _fullLoadCurrent * startingCurrentFactor;
      
      // Calculate system impedance for voltage drop calculation
      // Convert from % to per unit
      double systemZpu = systemImpedance / 100.0;
      double transformerZpu = transformerImpedance / 100.0;
      
      // Calculate transformer base impedance
      double systemMVA = transformerRating / 1000.0; // in MVA
      double transformerBaseZ = (voltage * voltage) / (transformerRating * 1000); // in ohms
      
      // Total system impedance in per unit
      double totalZpu = systemZpu + transformerZpu;
      
      // Calculate bus fault level (in MVA)
      _busFaultLevel = systemMVA / totalZpu;
      
      // Calculate voltage drop during starting (in %)
      double motorStartingMVA = (_startingCurrent * voltage * sqrt(3)) / 1000000; // in MVA
      _voltageDrop = (motorStartingMVA / _busFaultLevel) * 100;
      
      // Calculate approximate starting torque (assuming torque ~ V²)
      double relativeVoltage = (100 - _voltageDrop) / 100;
      _motorStartingTorque = (relativeVoltage * relativeVoltage) * 100; // in % of nominal
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  @override
  void dispose() {
    _motorRatingController.dispose();
    _powerFactorController.dispose();
    _efficiencyController.dispose();
    _voltageController.dispose();
    _startingFactorController.dispose();
    _systemImpedanceController.dispose();
    _transformerRatingController.dispose();
    _transformerImpedanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Starting Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motor parameters
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
                        'Motor Parameters',
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
                              title: Text('Induction Motor'),
                              value: 'induction',
                              groupValue: _motorType,
                              onChanged: (value) {
                                setState(() {
                                  _motorType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Synchronous Motor'),
                              value: 'synchronous',
                              groupValue: _motorType,
                              onChanged: (value) {
                                setState(() {
                                  _motorType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _motorRatingController,
                        decoration: InputDecoration(
                          labelText: 'Motor Rating (kW)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.power),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the motor rating';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _powerFactorController,
                              decoration: InputDecoration(
                                labelText: 'Power Factor (0-1)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.speed),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                double? pf = double.tryParse(value);
                                if (pf == null || pf <= 0 || pf > 1) {
                                  return 'Between 0-1';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _efficiencyController,
                              decoration: InputDecoration(
                                labelText: 'Efficiency (0-1)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.eco),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                double? eff = double.tryParse(value);
                                if (eff == null || eff <= 0 || eff > 1) {
                                  return 'Between 0-1';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _voltageController,
                        decoration: InputDecoration(
                          labelText: 'Motor Voltage (V)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electric_bolt),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the voltage';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _startingFactorController,
                        decoration: InputDecoration(
                          labelText: 'Starting Current Factor (LRC/FLC)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.show_chart),
                          helperText: 'Typically 5-7 for induction motors',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          double? factor = double.tryParse(value);
                          if (factor == null || factor <= 0) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Starting method
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
                        'Starting Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _startingMethod,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.play_circle),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'direct',
                            child: Text('Direct-On-Line (DOL)'),
                          ),
                          DropdownMenuItem(
                            value: 'star-delta',
                            child: Text('Star-Delta'),
                          ),
                          DropdownMenuItem(
                            value: 'autotransformer',
                            child: Text('Auto-transformer'),
                          ),
                          DropdownMenuItem(
                            value: 'soft-starter',
                            child: Text('Soft Starter'),
                          ),
                          DropdownMenuItem(
                            value: 'vfd',
                            child: Text('Variable Frequency Drive (VFD)'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _startingMethod = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      // Starting method description
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          _getStartingMethodDescription(),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // System parameters
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
                        'System Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _systemImpedanceController,
                        decoration: InputDecoration(
                          labelText: 'System Impedance (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                          helperText: 'Upstream impedance (grid)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the system impedance';
                          }
                          if (double.tryParse(value) == null || double.parse(value) < 0) {
                            return 'Please enter a valid non-negative number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _transformerRatingController,
                              decoration: InputDecoration(
                                labelText: 'Transformer Rating (kVA)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.transform),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _transformerImpedanceController,
                              decoration: InputDecoration(
                                labelText: 'Transformer Z (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.functions),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateMotorStarting,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Calculate Motor Starting',
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
              
              SizedBox(height: 24),
              
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
                              Icons.flash_on,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Motor Starting Results',
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
                          label: 'Full Load Current:',
                          value: '${_fullLoadCurrent.toStringAsFixed(2)} A',
                          icon: Icons.electric_bolt,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Starting Current:',
                          value: '${_startingCurrent.toStringAsFixed(2)} A',
                          icon: Icons.trending_up,
                          iconColor: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Voltage Drop:',
                          value: '${_voltageDrop.toStringAsFixed(2)}%',
                          icon: Icons.trending_down,
                          iconColor: _getVoltageDipColor(),
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Bus Fault Level:',
                          value: '${_busFaultLevel.toStringAsFixed(2)} MVA',
                          icon: Icons.power,
                          iconColor: Colors.purple,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Starting Torque:',
                          value: '${_motorStartingTorque.toStringAsFixed(2)}% of nominal',
                          icon: Icons.rotate_right,
                          iconColor: _getStartingTorqueColor(),
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
                                'Analysis:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildAnalysis(),
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
                        'About Motor Starting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Motor starting analysis is critical for power system engineers to ensure:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Voltage dips stay within acceptable limits',
                        icon: Icons.electric_bolt,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Adequate starting torque for the load',
                        icon: Icons.rotate_right,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Protection devices are properly coordinated',
                        icon: Icons.security,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Motor thermal limits aren\'t exceeded',
                        icon: Icons.thermostat,
                        iconColor: Colors.red,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show motor starting learning resources
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
  
  String _getStartingMethodDescription() {
    switch (_startingMethod) {
      case 'direct':
        return 'Direct-On-Line (DOL) starting applies full voltage to the motor terminals, resulting in maximum starting torque but also maximum starting current and voltage drop.';
      case 'star-delta':
        return 'Star-Delta starting initially connects the motor windings in star configuration, reducing the voltage by √3, then switches to delta for normal operation. Reduces starting current to about 33% of DOL.';
      case 'autotransformer':
        return 'Autotransformer starting uses a transformer to reduce the initial voltage applied to the motor, typically to 50-80% of nominal, reducing both starting current and torque.';
      case 'soft-starter':
        return 'Soft starters use solid-state devices to gradually increase voltage to the motor, providing smooth acceleration and reduced current inrush, typically 30-50% of DOL.';
      case 'vfd':
        return 'Variable Frequency Drives (VFDs) control both voltage and frequency, allowing precise control over motor acceleration and limiting starting current to as low as 100-150% of full load current.';
      default:
        return 'Select a starting method to see description.';
    }
  }
  
  Color _getVoltageDipColor() {
    if (_voltageDrop <= 5) {
      return Colors.green;
    } else if (_voltageDrop <= 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Color _getStartingTorqueColor() {
    if (_motorStartingTorque >= 50) {
      return Colors.green;
    } else if (_motorStartingTorque >= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Widget _buildAnalysis() {
    List<Widget> analysisItems = [];
    
    // Voltage drop analysis
    if (_voltageDrop <= 5) {
      analysisItems.add(
        Text('• Voltage drop is within acceptable limits (< 5%).', style: TextStyle(color: Colors.green)),
      );
    } else if (_voltageDrop <= 10) {
      analysisItems.add(
        Text('• Voltage drop is moderate (5-10%). May be acceptable for non-critical loads.', style: TextStyle(color: Colors.orange)),
      );
    } else if (_voltageDrop <= 15) {
      analysisItems.add(
        Text('• Voltage drop is high (10-15%). Consider reduced voltage starting methods.', style: TextStyle(color: Colors.deepOrange)),
      );
    } else {
      analysisItems.add(
        Text('• Voltage drop is excessive (>15%). Alternative starting method required.', style: TextStyle(color: Colors.red)),
      );
    }
    
    // Starting torque analysis
    if (_motorStartingTorque >= 50) {
      analysisItems.add(
        Text('• Starting torque is sufficient for most applications.', style: TextStyle(color: Colors.green)),
      );
    } else if (_motorStartingTorque >= 30) {
      analysisItems.add(
        Text('• Starting torque may be adequate for low-inertia loads only.', style: TextStyle(color: Colors.orange)),
      );
    } else {
      analysisItems.add(
        Text('• Starting torque is insufficient. Motor may not start successfully.', style: TextStyle(color: Colors.red)),
      );
    }
    
    // Starting current analysis
    double motorRating = double.parse(_motorRatingController.text);
    double transformerRating = double.parse(_transformerRatingController.text);
    double startingCurrentKVA = _startingCurrent * double.parse(_voltageController.text) * sqrt(3) / 1000;
    
    if (startingCurrentKVA <= transformerRating * 0.5) {
      analysisItems.add(
        Text('• Starting current is well within transformer capacity.', style: TextStyle(color: Colors.green)),
      );
    } else if (startingCurrentKVA <= transformerRating) {
      analysisItems.add(
        Text('• Starting current is significant but within transformer capacity.', style: TextStyle(color: Colors.orange)),
      );
    } else {
      analysisItems.add(
        Text('• Starting current exceeds transformer rating. Risk of protective devices tripping.', style: TextStyle(color: Colors.red)),
      );
    }
    
    // Motor size to transformer size ratio analysis
    double motorTransformerRatio = (motorRating / transformerRating) * 100;
    if (motorTransformerRatio <= 20) {
      analysisItems.add(
        Text('• Motor size is relatively small compared to transformer capacity.', style: TextStyle(color: Colors.green)),
      );
    } else if (motorTransformerRatio <= 50) {
      analysisItems.add(
        Text('• Motor-to-transformer size ratio is typical.', style: TextStyle(color: Colors.green)),
      );
    } else {
      analysisItems.add(
        Text('• Motor is large relative to transformer capacity. Consider upsizing transformer.', style: TextStyle(color: Colors.orange)),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: analysisItems,
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