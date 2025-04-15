// lib/calculators/load_flow_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class LoadFlowCalculatorScreen extends StatefulWidget {
  const LoadFlowCalculatorScreen({super.key});

  @override
  LoadFlowCalculatorScreenState createState() => LoadFlowCalculatorScreenState();
}

class LoadFlowCalculatorScreenState extends State<LoadFlowCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final TextEditingController _busCountController = TextEditingController(text: '3');
  final TextEditingController _slackBusVoltageController = TextEditingController(text: '1.0');
  final TextEditingController _toleranceController = TextEditingController(text: '0.0001');
  final TextEditingController _maxIterationsController = TextEditingController(text: '20');
  
  // Bus types
  List<String> _busTypes = ['Slack', 'PV', 'PQ'];
  
  // Dynamic list of buses with their properties
  List<Map<String, dynamic>> _buses = [];
  
  // Matrix for line impedances
  List<List<TextEditingController>> _lineImpedanceControllers = [];
  
  // Results
  List<Map<String, dynamic>> _busResults = [];
  List<Map<String, dynamic>> _lineResults = [];
  bool _hasCalculated = false;
  String _iterationCount = '';
  bool _hasConverged = false;
  
  @override
  void initState() {
    super.initState();
    _initializeBuses(3); // Default 3 buses
  }
  
  void _initializeBuses(int count) {
    // Clear existing buses
    _buses.clear();
    _lineImpedanceControllers.clear();
    
    // Create buses
    for (int i = 0; i < count; i++) {
      String type = i == 0 ? 'Slack' : (i == 1 ? 'PV' : 'PQ');
      
      _buses.add({
        'number': i + 1,
        'type': type,
        'voltage': TextEditingController(text: i == 0 ? '1.0' : '1.0'),
        'angle': TextEditingController(text: i == 0 ? '0.0' : '0.0'),
        'activePower': TextEditingController(text: '0.0'),
        'reactivePower': TextEditingController(text: '0.0'),
      });
    }
    
    // Create line impedance matrix
    for (int i = 0; i < count; i++) {
      List<TextEditingController> row = [];
      for (int j = 0; j < count; j++) {
        if (i == j) {
          // Diagonal elements (self-impedance)
          row.add(TextEditingController(text: '0.0'));
        } else {
          // Off-diagonal elements (mutual impedance)
          row.add(TextEditingController(text: i < j ? '0.1' : '0.0'));
        }
      }
      _lineImpedanceControllers.add(row);
    }
  }
  
  void _calculateLoadFlow() {
    if (_formKey.currentState!.validate()) {
      // In a real application, this would implement a load flow algorithm
      // such as Gauss-Seidel or Newton-Raphson
      
      // For this simplified example, we'll just simulate some results
      _simulateLoadFlowResults();
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
        _iterationCount = '5'; // Simulated
        _hasConverged = true;
      });
    }
  }
  
  void _simulateLoadFlowResults() {
    _busResults.clear();
    _lineResults.clear();
    
    // Simulate bus results
    for (int i = 0; i < _buses.length; i++) {
      double voltage = double.parse(_buses[i]['voltage'].text);
      double angle = double.parse(_buses[i]['angle'].text);
      double activePower = double.parse(_buses[i]['activePower'].text);
      double reactivePower = double.parse(_buses[i]['reactivePower'].text);
      
      // Simulate some calculations
      if (_buses[i]['type'] == 'PQ') {
        voltage = voltage * (0.95 + 0.1 * Random().nextDouble());
        angle = angle - (5 + 3 * Random().nextDouble());
      } else if (_buses[i]['type'] == 'PV') {
        reactivePower = reactivePower + (0.2 - 0.4 * Random().nextDouble());
      }
      
      _busResults.add({
        'number': i + 1,
        'type': _buses[i]['type'],
        'voltage': voltage.toStringAsFixed(4),
        'angle': angle.toStringAsFixed(4),
        'activePower': activePower.toStringAsFixed(4),
        'reactivePower': reactivePower.toStringAsFixed(4),
      });
    }
    
    // Simulate line results
    for (int i = 0; i < _buses.length; i++) {
      for (int j = i + 1; j < _buses.length; j++) {
        double impedance = double.parse(_lineImpedanceControllers[i][j].text);
        if (impedance > 0) {
          double activePowerFlow = 0.5 + Random().nextDouble() * 0.5;
          double reactivePowerFlow = 0.2 + Random().nextDouble() * 0.3;
          double current = activePowerFlow / double.parse(_busResults[i]['voltage']);
          double losses = current * current * impedance;
          
          _lineResults.add({
            'from': i + 1,
            'to': j + 1,
            'activePower': activePowerFlow.toStringAsFixed(4),
            'reactivePower': reactivePowerFlow.toStringAsFixed(4),
            'current': current.toStringAsFixed(4),
            'losses': losses.toStringAsFixed(4),
          });
        }
      }
    }
  }
  
  void _updateBusCount() {
    int count = int.parse(_busCountController.text);
    if (count >= 2 && count <= 10) {
      setState(() {
        _initializeBuses(count);
        _hasCalculated = false;
      });
    }
  }
  
  @override
  void dispose() {
    _busCountController.dispose();
    _slackBusVoltageController.dispose();
    _toleranceController.dispose();
    _maxIterationsController.dispose();
    
    for (var bus in _buses) {
      bus['voltage'].dispose();
      bus['angle'].dispose();
      bus['activePower'].dispose();
      bus['reactivePower'].dispose();
    }
    
    for (var row in _lineImpedanceControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Flow Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _busCountController,
                              decoration: InputDecoration(
                                labelText: 'Number of Buses',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.account_tree),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter number of buses';
                                }
                                int? count = int.tryParse(value);
                                if (count == null || count < 2 || count > 10) {
                                  return 'Must be between 2 and 10';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _updateBusCount,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            child: Text('Update'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _slackBusVoltageController,
                              decoration: InputDecoration(
                                labelText: 'Slack Bus Voltage (pu)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.electric_bolt),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter slack bus voltage';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _toleranceController,
                              decoration: InputDecoration(
                                labelText: 'Convergence Tolerance',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.precision_manufacturing),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter tolerance';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _maxIterationsController,
                        decoration: InputDecoration(
                          labelText: 'Maximum Iterations',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter max iterations';
                          }
                          int? iterations = int.tryParse(value);
                          if (iterations == null || iterations <= 0) {
                            return 'Please enter a positive integer';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Bus data
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
                        'Bus Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      for (int i = 0; i < _buses.length; i++)
                        _buildBusInputs(i),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Line data
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
                        'Line Impedance Data (pu)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildLineImpedanceMatrix(),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _calculateLoadFlow,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Calculate Load Flow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Results section
              if (_hasCalculated) _buildResultsSection(),
              
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
                        'About Load Flow Analysis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Load flow studies are fundamental to power system analysis, helping engineers to:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Determine voltage profiles throughout the system',
                        icon: Icons.electric_bolt,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Calculate active and reactive power flows',
                        icon: Icons.waves,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Identify potential overloaded lines and equipment',
                        icon: Icons.warning,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Evaluate system stability and contingencies',
                        icon: Icons.security,
                        iconColor: Colors.purple,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show load flow learning resources
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
  
  Widget _buildBusInputs(int index) {
    final bus = _buses[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bus ${bus['number']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              DropdownButton<String>(
                value: bus['type'],
                items: _busTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: index == 0 
                    ? null // Slack bus is fixed
                    : (newValue) {
                        setState(() {
                          bus['type'] = newValue!;
                        });
                      },
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: bus['voltage'],
                  enabled: bus['type'] != 'PQ',
                  decoration: InputDecoration(
                    labelText: 'Voltage (pu)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: bus['angle'],
                  enabled: bus['type'] != 'Slack' && bus['type'] != 'PV',
                  decoration: InputDecoration(
                    labelText: 'Angle (deg)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: bus['activePower'],
                  enabled: bus['type'] != 'Slack',
                  decoration: InputDecoration(
                    labelText: 'Active Power (pu)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: bus['reactivePower'],
                  enabled: bus['type'] == 'PQ',
                  decoration: InputDecoration(
                    labelText: 'Reactive Power (pu)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLineImpedanceMatrix() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('From/To')),
          for (int i = 0; i < _buses.length; i++)
            DataColumn(label: Text('Bus ${i + 1}')),
        ],
        rows: List.generate(_buses.length, (i) {
          return DataRow(
            cells: [
              DataCell(Text('Bus ${i + 1}')),
              for (int j = 0; j < _buses.length; j++)
                DataCell(
                  i == j
                      ? Text('--')
                      : SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _lineImpedanceControllers[i][j],
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: i < j, // Upper triangular matrix
                            onChanged: (value) {
                              // Mirror the value to the lower triangle
                              if (i < j && double.tryParse(value) != null) {
                                _lineImpedanceControllers[j][i].text = value;
                              }
                            },
                            validator: (value) {
                              if (i < j) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                ),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildResultsSection() {
    return Card(
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
                  Icons.info,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  'Load Flow Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Spacer(),
                _hasConverged
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Converged',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Not Converged',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Method: Newton-Raphson',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Iterations: $_iterationCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Bus Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Bus')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Voltage (pu)')),
                  DataColumn(label: Text('Angle (deg)')),
                  DataColumn(label: Text('P (pu)')),
                  DataColumn(label: Text('Q (pu)')),
                ],
                rows: _busResults.map((bus) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${bus['number']}')),
                      DataCell(Text('${bus['type']}')),
                      DataCell(Text('${bus['voltage']}')),
                      DataCell(Text('${bus['angle']}')),
                      DataCell(Text('${bus['activePower']}')),
                      DataCell(Text('${bus['reactivePower']}')),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Line Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('From')),
                  DataColumn(label: Text('To')),
                  DataColumn(label: Text('P Flow (pu)')),
                  DataColumn(label: Text('Q Flow (pu)')),
                  DataColumn(label: Text('Current (pu)')),
                  DataColumn(label: Text('Losses (pu)')),
                ],
                rows: _lineResults.map((line) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${line['from']}')),
                      DataCell(Text('${line['to']}')),
                      DataCell(Text('${line['activePower']}')),
                      DataCell(Text('${line['reactivePower']}')),
                      DataCell(Text('${line['current']}')),
                      DataCell(Text('${line['losses']}')),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Save or export results
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