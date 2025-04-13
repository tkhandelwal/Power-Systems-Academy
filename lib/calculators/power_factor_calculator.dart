// lib/calculators/power_factor_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class PowerFactorCalculatorScreen extends StatefulWidget {
  const PowerFactorCalculatorScreen({super.key});

  @override
  _PowerFactorCalculatorScreenState createState() => _PowerFactorCalculatorScreenState();
}

class _PowerFactorCalculatorScreenState extends State<PowerFactorCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _existingPowerController = TextEditingController();
  final TextEditingController _existingPowerFactorController = TextEditingController();
  final TextEditingController _targetPowerFactorController = TextEditingController();
  final TextEditingController _systemVoltageController = TextEditingController();
  final TextEditingController _systemFrequencyController = TextEditingController(text: '60');
  
  // System type
  String _systemType = 'single-phase'; // 'single-phase' or 'three-phase'
  
  // Results
  double _requiredKVAR = 0.0;
  double _capacitorCurrent = 0.0;
  double _capacitanceValue = 0.0;
  double _powerSavings = 0.0;
  bool _hasCalculated = false;
  
  // Calculate power factor correction
  void _calculateCorrection() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double existingPower = double.parse(_existingPowerController.text); // in kW
      double existingPF = double.parse(_existingPowerFactorController.text);
      double targetPF = double.parse(_targetPowerFactorController.text);
      double voltage = double.parse(_systemVoltageController.text); // in V
      double frequency = double.parse(_systemFrequencyController.text); // in Hz
      
      // Ensure power factors are between 0 and 1
      existingPF = existingPF.clamp(0.0, 1.0);
      targetPF = targetPF.clamp(0.0, 1.0);
      
      // Convert kW to W for calculations
      existingPower *= 1000;
      
      // Calculate phase angles
      double existingAngle = acos(existingPF);
      double targetAngle = acos(targetPF);
      
      // Calculate existing reactive power
      double existingReactivePower = existingPower * tan(existingAngle);
      
      // Calculate target reactive power
      double targetReactivePower = existingPower * tan(targetAngle);
      
      // Calculate required reactive power compensation
      double requiredReactivePower = existingReactivePower - targetReactivePower;
      
      // Convert W to kVAR for display
      _requiredKVAR = requiredReactivePower / 1000;
      
      // Calculate capacitor current
      if (_systemType == 'single-phase') {
        _capacitorCurrent = requiredReactivePower / voltage;
      } else {
        // Three-phase calculation
        _capacitorCurrent = requiredReactivePower / (sqrt(3) * voltage);
      }
      
      // Calculate capacitance value in microfarads
      // For single-phase: C = Q / (2πfV²)
      // For three-phase: C = Q / (2πf√3V²) per phase (Delta)
      double angularFrequency = 2 * pi * frequency;
      
      if (_systemType == 'single-phase') {
        _capacitanceValue = requiredReactivePower / (angularFrequency * pow(voltage, 2));
      } else {
        // Three-phase calculation (for delta connection)
        _capacitanceValue = requiredReactivePower / (3 * angularFrequency * pow(voltage, 2));
      }
      
      // Convert to microfarads
      _capacitanceValue *= 1E6;
      
      // Calculate power savings (approximate)
      double existingApparentPower = existingPower / existingPF;
      double newApparentPower = existingPower / targetPF;
      double apparentPowerSavings = existingApparentPower - newApparentPower;
      
      // Assuming a typical efficiency improvement of around 2-5% of the difference
      _powerSavings = apparentPowerSavings * 0.03 / 1000; // Convert to kW
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  @override
  void dispose() {
    _existingPowerController.dispose();
    _existingPowerFactorController.dispose();
    _targetPowerFactorController.dispose();
    _systemVoltageController.dispose();
    _systemFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Factor Correction'),
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
                              groupValue: _systemType,
                              onChanged: (value) {
                                setState(() {
                                  _systemType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Three-Phase'),
                              value: 'three-phase',
                              groupValue: _systemType,
                              onChanged: (value) {
                                setState(() {
                                  _systemType = value!;
                                });
                              },
                            ),
                          ),
                        ],
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
                        'Load Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _existingPowerController,
                        decoration: InputDecoration(
                          labelText: 'Real Power (kW)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.power),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the real power';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _existingPowerFactorController,
                        decoration: InputDecoration(
                          labelText: 'Existing Power Factor (0 to 1)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.speed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the existing power factor';
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
                        controller: _targetPowerFactorController,
                        decoration: InputDecoration(
                          labelText: 'Target Power Factor (0 to 1)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the target power factor';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Please enter a valid number';
                          }
                          if (number <= 0 || number > 1) {
                            return 'Power factor must be between 0 and 1';
                          }
                          
                          // Validate that target PF is higher than existing PF
                          if (_existingPowerFactorController.text.isNotEmpty) {
                            double existingPF = double.parse(_existingPowerFactorController.text);
                            if (number <= existingPF) {
                              return 'Target PF must be higher than existing PF';
                            }
                          }
                          
                          return null;
                        },
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
                        controller: _systemVoltageController,
                        decoration: InputDecoration(
                          labelText: _systemType == 'single-phase' 
                              ? 'System Voltage (V)' 
                              : 'System Line Voltage (V)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the system voltage';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _systemFrequencyController,
                        decoration: InputDecoration(
                          labelText: 'System Frequency (Hz)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.waves),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the system frequency';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateCorrection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Calculate Correction',
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Correction Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ResultItem(
                          label: 'Required Reactive Power:',
                          value: '${_requiredKVAR.toStringAsFixed(2)} kVAR',
                          icon: Icons.power_input,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Capacitor Current:',
                          value: '${_capacitorCurrent.toStringAsFixed(2)} A',
                          icon: Icons.electric_bolt,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Capacitance Required:',
                          value: '${_capacitanceValue.toStringAsFixed(2)} μF',
                          icon: Icons.battery_charging_full,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Estimated Power Savings:',
                          value: '${_powerSavings.toStringAsFixed(2)} kW',
                          icon: Icons.savings,
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
                                'Notes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• The actual capacitance required may vary based on equipment specifications.',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Power savings are an estimate and may vary in real-world applications.',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• For three-phase systems, capacitance shown is per phase (Delta connection).',
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
                        'About Power Factor Correction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Power factor correction is the process of increasing the power factor of an electrical system by adding capacitors to counteract inductive loads. Benefits include:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Reduced electricity bills and demand charges',
                        icon: Icons.attach_money,
                      ),
                      BenefitItem(
                        text: 'Improved voltage regulation and system capacity',
                        icon: Icons.trending_up,
                      ),
                      BenefitItem(
                        text: 'Decreased line losses and heat generation',
                        icon: Icons.eco,
                      ),
                      BenefitItem(
                        text: 'Extended equipment life and reliability',
                        icon: Icons.access_time,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show power factor learning resources
                              },
                              icon: Icon(Icons.book),
                              label: Text('Learn More'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
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

  const ResultItem({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
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

  const BenefitItem({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

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
            color: Colors.green,
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