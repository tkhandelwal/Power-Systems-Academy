// lib/calculators/short_circuit_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ShortCircuitCalculatorScreen extends StatefulWidget {
  const ShortCircuitCalculatorScreen({super.key});

  @override
  ShortCircuitCalculatorScreenState createState() => ShortCircuitCalculatorScreenState();
}

class ShortCircuitCalculatorScreenState extends State<ShortCircuitCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _systemVoltageController = TextEditingController();
  final TextEditingController _systemMVAController = TextEditingController();
  final TextEditingController _systemXRRatioController = TextEditingController(text: '10');
  final TextEditingController _transformerRatingController = TextEditingController();
  final TextEditingController _transformerImpedanceController = TextEditingController();
  final TextEditingController _transformerXRRatioController = TextEditingController(text: '7');
  final TextEditingController _cableResistanceController = TextEditingController(text: '0');
  final TextEditingController _cableReactanceController = TextEditingController(text: '0');
  final TextEditingController _cableLengthController = TextEditingController(text: '0');
  
  // System parameters
  String _calculationType = 'simplified'; // 'simplified' or 'detailed'
  String _systemType = 'three-phase'; // 'three-phase' or 'single-phase'
  String _faultType = 'three-phase'; // 'three-phase', 'line-line', 'line-ground', 'line-line-ground'
  String _standardType = 'ansi'; // 'ansi' or 'iec'
  
  // Results
  double _symmetricalFaultCurrent = 0.0;
  double _asymmetricalFaultCurrent = 0.0;
  double _peakFaultCurrent = 0.0;
  double _totalImpedance = 0.0;
  double _totalReactance = 0.0;
  double _totalResistance = 0.0;
  double _faultMVA = 0.0;
  bool _hasCalculated = false;
  
  // Calculate short circuit currents
  void _calculateShortCircuit() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      double systemVoltage = double.parse(_systemVoltageController.text); // in kV
      double systemMVA = double.parse(_systemMVAController.text); // in MVA
      double systemXRRatio = double.parse(_systemXRRatioController.text); 
      double transformerRating = double.parse(_transformerRatingController.text); // in MVA
      double transformerImpedance = double.parse(_transformerImpedanceController.text); // in %
      double transformerXRRatio = double.parse(_transformerXRRatioController.text);
      double cableResistance = double.parse(_cableResistanceController.text); // in ohms/km
      double cableReactance = double.parse(_cableReactanceController.text); // in ohms/km
      double cableLength = double.parse(_cableLengthController.text); // in meters
      
      // Convert cable length from meters to kilometers
      cableLength = cableLength / 1000.0;
      
      // Base impedance at system voltage (in ohms)
      double baseImpedance = (systemVoltage * systemVoltage * 1000) / systemMVA;
      
      // Calculate system impedance in pu
      double systemImpedance = 1.0 / systemMVA;
      double systemReactance = systemImpedance / sqrt(1 + (1 / (systemXRRatio * systemXRRatio)));
      double systemResistance = systemReactance / systemXRRatio;
      
      // Calculate transformer impedance in pu
      double transformerImpedancePU = transformerImpedance / 100.0; // Convert from % to pu
      double baseTransformerImpedance = transformerImpedancePU * (systemMVA / transformerRating);
      double transformerReactance = baseTransformerImpedance / sqrt(1 + (1 / (transformerXRRatio * transformerXRRatio)));
      double transformerResistance = transformerReactance / transformerXRRatio;
      
      // Calculate cable impedance in ohms
      double cableTotalResistance = cableResistance * cableLength;
      double cableTotalReactance = cableReactance * cableLength;
      
      // Convert cable impedance to pu
      double cableResistancePU = cableTotalResistance / baseImpedance;
      double cableReactancePU = cableTotalReactance / baseImpedance;
      
      // Calculate total resistance and reactance in pu
      _totalResistance = systemResistance + transformerResistance + cableResistancePU;
      _totalReactance = systemReactance + transformerReactance + cableReactancePU;
      
      // Calculate total impedance in pu
      _totalImpedance = sqrt(_totalResistance * _totalResistance + _totalReactance * _totalReactance);
      
      // Base current at system voltage (in kA)
      double baseCurrent = systemMVA / (sqrt(3) * systemVoltage);
      
      // Calculate symmetrical fault current based on fault type
      double faultFactor;
      if (_faultType == 'three-phase') {
        faultFactor = 1.0;
      } else if (_faultType == 'line-line') {
        faultFactor = sqrt(3) / 2.0;
      } else if (_faultType == 'line-ground') {
        // Simplified approximation for SLG fault (assuming X0 = X1)
        faultFactor = 3.0 / 2.0;
      } else { // line-line-ground
        // Simplified approximation for DLG fault (assuming X0 = X1)
        faultFactor = sqrt(3);
      }
      
      // Calculate symmetrical fault current in kA
      _symmetricalFaultCurrent = (1.0 / _totalImpedance) * baseCurrent * faultFactor;
      
      // Calculate asymmetrical factor based on X/R ratio
      double systemTotalXRRatio = _totalReactance / _totalResistance;
      double asymmetricalFactor;
      
      if (_standardType == 'ansi') {
        // ANSI method
        asymmetricalFactor = 1.0 + exp(-2 * pi * 0.005 / (systemTotalXRRatio / (2 * pi * 60)));
      } else {
        // IEC method
        asymmetricalFactor = sqrt(1.0 + 2 * exp(-3 * _totalResistance / _totalReactance));
      }
      
      // Calculate asymmetrical fault current in kA
      _asymmetricalFaultCurrent = _symmetricalFaultCurrent * asymmetricalFactor;
      
      // Calculate peak fault current in kA
      double peakFactor;
      if (_standardType == 'ansi') {
        peakFactor = 2.7; // Typical ANSI value
      } else {
        // IEC method
        peakFactor = sqrt(2) * (1.02 + 0.98 * exp(-3 * _totalResistance / _totalReactance));
      }
      _peakFaultCurrent = _symmetricalFaultCurrent * peakFactor;
      
      // Calculate fault MVA
      _faultMVA = sqrt(3) * systemVoltage * _symmetricalFaultCurrent;
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  @override
  void dispose() {
    _systemVoltageController.dispose();
    _systemMVAController.dispose();
    _systemXRRatioController.dispose();
    _transformerRatingController.dispose();
    _transformerImpedanceController.dispose();
    _transformerXRRatioController.dispose();
    _cableResistanceController.dispose();
    _cableReactanceController.dispose();
    _cableLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Short Circuit Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calculation type selector
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
                        'Calculation Settings',
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
                              title: Text('Simplified'),
                              value: 'simplified',
                              groupValue: _calculationType,
                              onChanged: (value) {
                                setState(() {
                                  _calculationType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Detailed'),
                              value: 'detailed',
                              groupValue: _calculationType,
                              onChanged: (value) {
                                setState(() {
                                  _calculationType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('ANSI Standard'),
                              value: 'ansi',
                              groupValue: _standardType,
                              onChanged: (value) {
                                setState(() {
                                  _standardType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('IEC Standard'),
                              value: 'iec',
                              groupValue: _standardType,
                              onChanged: (value) {
                                setState(() {
                                  _standardType = value!;
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
              
              // System type and fault type selector
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
                                  // Reset fault type for single-phase
                                  if (value == 'single-phase') {
                                    _faultType = 'line-ground';
                                  }
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
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _faultType,
                        decoration: InputDecoration(
                          labelText: 'Fault Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.flash_on),
                        ),
                        items: _systemType == 'three-phase' 
                            ? [
                                DropdownMenuItem(
                                  value: 'three-phase',
                                  child: Text('Three-Phase Fault'),
                                ),
                                DropdownMenuItem(
                                  value: 'line-line',
                                  child: Text('Line-to-Line Fault'),
                                ),
                                DropdownMenuItem(
                                  value: 'line-ground',
                                  child: Text('Line-to-Ground Fault'),
                                ),
                                DropdownMenuItem(
                                  value: 'line-line-ground',
                                  child: Text('Double Line-to-Ground Fault'),
                                ),
                              ] 
                            : [
                                DropdownMenuItem(
                                  value: 'line-ground',
                                  child: Text('Line-to-Ground Fault'),
                                ),
                              ],
                        onChanged: (value) {
                          setState(() {
                            _faultType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Utility/Grid parameters
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
                        'Utility / Grid Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _systemVoltageController,
                        decoration: InputDecoration(
                          labelText: 'System Voltage (kV)',
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
                        controller: _systemMVAController,
                        decoration: InputDecoration(
                          labelText: 'Short Circuit Capacity (MVA)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.power),
                          helperText: 'Utility available fault MVA',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the short circuit capacity';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _systemXRRatioController,
                        decoration: InputDecoration(
                          labelText: 'System X/R Ratio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.functions),
                          helperText: 'Typically 10-20 for utility',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the X/R ratio';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Transformer parameters
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
                        'Transformer Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _transformerRatingController,
                        decoration: InputDecoration(
                          labelText: 'Transformer Rating (MVA)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.transform),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the transformer rating';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _transformerImpedanceController,
                        decoration: InputDecoration(
                          labelText: 'Transformer Impedance (%)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.power_input),
                          helperText: 'Typically 5-8% for power transformers',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the transformer impedance';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _transformerXRRatioController,
                        decoration: InputDecoration(
                          labelText: 'Transformer X/R Ratio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.functions),
                          helperText: 'Typically 7-10 for power transformers',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the X/R ratio';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Cable parameters (only shown in detailed mode)
              if (_calculationType == 'detailed')
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
                          'Cable Parameters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _cableResistanceController,
                          decoration: InputDecoration(
                            labelText: 'Cable Resistance (Ω/km)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.power_input),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the cable resistance';
                            }
                            if (double.tryParse(value) == null || double.parse(value) < 0) {
                              return 'Please enter a valid non-negative number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _cableReactanceController,
                          decoration: InputDecoration(
                            labelText: 'Cable Reactance (Ω/km)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.power_input),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the cable reactance';
                            }
                            if (double.tryParse(value) == null || double.parse(value) < 0) {
                              return 'Please enter a valid non-negative number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _cableLengthController,
                          decoration: InputDecoration(
                            labelText: 'Cable Length (m)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the cable length';
                            }
                            if (double.tryParse(value) == null || double.parse(value) < 0) {
                              return 'Please enter a valid non-negative number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _calculateShortCircuit,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Calculate Short Circuit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                              color: Colors.red,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Short Circuit Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ResultItem(
                          label: 'Symmetrical Fault Current:',
                          value: '${_symmetricalFaultCurrent.toStringAsFixed(2)} kA',
                          icon: Icons.bolt,
                          iconColor: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Asymmetrical Fault Current:',
                          value: '${_asymmetricalFaultCurrent.toStringAsFixed(2)} kA',
                          icon: Icons.bolt,
                          iconColor: Colors.red,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Peak Fault Current:',
                          value: '${_peakFaultCurrent.toStringAsFixed(2)} kA',
                          icon: Icons.bolt,
                          iconColor: Colors.deepOrange,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Fault MVA:',
                          value: '${_faultMVA.toStringAsFixed(2)} MVA',
                          icon: Icons.power,
                          iconColor: Colors.purple,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Impedance Components:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Total Resistance:',
                          value: '${_totalResistance.toStringAsFixed(4)} pu',
                          icon: Icons.power_input,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Total Reactance:',
                          value: '${_totalReactance.toStringAsFixed(4)} pu',
                          icon: Icons.power_input,
                          iconColor: Colors.green,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Total Impedance:',
                          value: '${_totalImpedance.toStringAsFixed(4)} pu',
                          icon: Icons.power_input,
                          iconColor: Colors.indigo,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'X/R Ratio:',
                          value: (_totalReactance / _totalResistance).toStringAsFixed(2),
                          icon: Icons.functions,
                          iconColor: Colors.teal,
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
                                '• Symmetrical fault current is the RMS value after DC component decays.',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Asymmetrical fault current includes the DC component for circuit breaker selection.',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                '• Peak fault current is used for equipment bracing and mechanical stress.',
                                style: TextStyle(fontSize: 12),
                              ),
                              if (_standardType == 'ansi')
                                Text(
                                  '• Calculated per ANSI C37.010/C37.13 standards.',
                                  style: TextStyle(fontSize: 12),
                                )
                              else
                                Text(
                                  '• Calculated per IEC 60909 standard.',
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
                        'About Short Circuit Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Short circuit analysis is essential for designing safe and reliable power systems. Key considerations include:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Equipment selection based on interrupting capacity and withstand ratings',
                        icon: Icons.security,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Protective device coordination for selective fault clearing',
                        icon: Icons.policy,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Protection against thermal and mechanical stresses during faults',
                        icon: Icons.warning,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Compliance with NEC, IEEE, and other applicable standards',
                        icon: Icons.gavel,
                        iconColor: Colors.purple,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show more information resources
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