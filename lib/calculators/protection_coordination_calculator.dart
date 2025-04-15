// lib/calculators/protection_coordination_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ProtectionCoordinationCalculatorScreen extends StatefulWidget {
  const ProtectionCoordinationCalculatorScreen({super.key});

  @override
  ProtectionCoordinationCalculatorScreenState createState() => ProtectionCoordinationCalculatorScreenState();
}

class ProtectionCoordinationCalculatorScreenState extends State<ProtectionCoordinationCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for upstream device
  final TextEditingController _upstreamTypeController = TextEditingController(text: 'Fuse');
  final TextEditingController _upstreamSizeController = TextEditingController();
  final TextEditingController _upstreamDelayController = TextEditingController(text: '0');
  
  // Controllers for downstream device
  final TextEditingController _downstreamTypeController = TextEditingController(text: 'Circuit Breaker');
  final TextEditingController _downstreamSizeController = TextEditingController();
  final TextEditingController _downstreamDelayController = TextEditingController(text: '0');
  
  // Fault currents
  final TextEditingController _faultCurrentController = TextEditingController();
  final TextEditingController _pickupCurrentController = TextEditingController();
  
  // Device options
  List<String> deviceTypes = ['Fuse', 'Circuit Breaker', 'Relay'];
  
  // Results
  bool _isCoordinated = false;
  bool _hasCalculated = false;
  String _coordinationMessage = '';
  double _upstreamTripTime = 0.0;
  double _downstreamTripTime = 0.0;
  double _marginTime = 0.0;
  
  void _calculateCoordination() {
    if (_formKey.currentState!.validate()) {
      // Parse input values
      String upstreamType = _upstreamTypeController.text;
      double upstreamSize = double.parse(_upstreamSizeController.text);
      double upstreamDelay = double.parse(_upstreamDelayController.text);
      
      String downstreamType = _downstreamTypeController.text;
      double downstreamSize = double.parse(_downstreamSizeController.text);
      double downstreamDelay = double.parse(_downstreamDelayController.text);
      
      double faultCurrent = double.parse(_faultCurrentController.text);
      double pickupCurrent = double.parse(_pickupCurrentController.text);
      
      // Simplified calculation for demonstration
      // In reality, this would use complex TCC curves based on device characteristics
      
      // Calculate operating times based on device type and sizing
      _downstreamTripTime = _calculateTripTime(downstreamType, downstreamSize, faultCurrent, pickupCurrent) + downstreamDelay;
      _upstreamTripTime = _calculateTripTime(upstreamType, upstreamSize, faultCurrent, pickupCurrent) + upstreamDelay;
      
      // Check coordination
      _marginTime = _upstreamTripTime - _downstreamTripTime;
      
      // Determine if the devices are coordinated
      double requiredMargin = _getRequiredMargin(downstreamType, upstreamType);
      _isCoordinated = _marginTime >= requiredMargin;
      
      // Set coordination message
      if (_isCoordinated) {
        _coordinationMessage = 'Devices are properly coordinated with ${_marginTime.toStringAsFixed(2)} seconds margin.';
      } else {
        if (_marginTime < 0) {
          _coordinationMessage = 'Upstream device operates faster than downstream device. Coordination failed.';
        } else {
          _coordinationMessage = 'Insufficient margin between devices. Need at least ${requiredMargin.toStringAsFixed(2)} seconds.';
        }
      }
      
      // Update state to show results
      setState(() {
        _hasCalculated = true;
      });
    }
  }
  
  double _calculateTripTime(String deviceType, double deviceSize, double faultCurrent, double pickupCurrent) {
    // This is a simplified model - real implementation would use actual curves
    double multiplier = faultCurrent / deviceSize;
    
    switch (deviceType) {
      case 'Fuse':
        // Simplified fuse curve approximation
        return 0.1 / pow(multiplier - 1, 2);
      case 'Circuit Breaker':
        // Simplified circuit breaker curve
        if (multiplier < 1.5) {
          return 10.0; // Long time region
        } else if (multiplier < 10) {
          return 10.0 / pow(multiplier / 1.5, 2); // Inverse time region
        } else {
          return 0.05; // Instantaneous region
        }
      case 'Relay':
        // Simplified relay curve (IEC Very Inverse)
        double pickupMultiplier = faultCurrent / pickupCurrent;
        if (pickupMultiplier < 1.0) {
          return double.infinity; // Below pickup
        }
        return 13.5 / (pow(pickupMultiplier, 1) - 1);
      default:
        return 0.1;
    }
  }
  
  double _getRequiredMargin(String downstreamType, String upstreamType) {
    // Required coordination margins between different device types
    if (downstreamType == 'Fuse' && upstreamType == 'Fuse') {
      return 0.1; // Fuse-fuse coordination
    } else if (downstreamType == 'Circuit Breaker' && upstreamType == 'Fuse') {
      return 0.2; // Breaker-fuse coordination
    } else if (downstreamType == 'Circuit Breaker' && upstreamType == 'Circuit Breaker') {
      return 0.3; // Breaker-breaker coordination
    } else if (upstreamType == 'Relay') {
      return 0.4; // Any device with relay coordination
    } else {
      return 0.2; // Default margin
    }
  }
  
  @override
  void dispose() {
    _upstreamTypeController.dispose();
    _upstreamSizeController.dispose();
    _upstreamDelayController.dispose();
    _downstreamTypeController.dispose();
    _downstreamSizeController.dispose();
    _downstreamDelayController.dispose();
    _faultCurrentController.dispose();
    _pickupCurrentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protection Coordination Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        'Downstream Device (Closer to Load)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _downstreamTypeController.text,
                        decoration: InputDecoration(
                          labelText: 'Device Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        items: deviceTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _downstreamTypeController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a device type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _downstreamSizeController,
                              decoration: InputDecoration(
                                labelText: 'Device Size (A)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.trending_up),
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
                              controller: _downstreamDelayController,
                              decoration: InputDecoration(
                                labelText: 'Time Delay (s)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) < 0) {
                                  return 'Invalid value';
                                }
                                return null;
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
                        'Upstream Device (Closer to Source)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _upstreamTypeController.text,
                        decoration: InputDecoration(
                          labelText: 'Device Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electrical_services),
                        ),
                        items: deviceTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _upstreamTypeController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a device type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _upstreamSizeController,
                              decoration: InputDecoration(
                                labelText: 'Device Size (A)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.trending_up),
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
                              controller: _upstreamDelayController,
                              decoration: InputDecoration(
                                labelText: 'Time Delay (s)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) < 0) {
                                  return 'Invalid value';
                                }
                                return null;
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
                        'Fault Parameters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _faultCurrentController,
                        decoration: InputDecoration(
                          labelText: 'Fault Current (A)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.flash_on),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the fault current';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _pickupCurrentController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Current (A)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.electric_bolt),
                          helperText: 'For relay devices',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_downstreamTypeController.text == 'Relay' || _upstreamTypeController.text == 'Relay') {
                            if (value == null || value.isEmpty) {
                              return 'Required for relay devices';
                            }
                            if (double.tryParse(value) == null || double.parse(value) <= 0) {
                              return 'Please enter a valid positive number';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _calculateCoordination,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Check Coordination',
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
              
              if (_hasCalculated)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: _isCoordinated ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isCoordinated ? Icons.check_circle : Icons.error,
                              color: _isCoordinated ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Coordination Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isCoordinated ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isCoordinated ? Colors.green.shade200 : Colors.red.shade200,
                            ),
                          ),
                          child: Text(
                            _coordinationMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isCoordinated ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ResultItem(
                          label: 'Downstream Device Trip Time:',
                          value: '${_downstreamTripTime.toStringAsFixed(3)} s',
                          icon: Icons.timer,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Upstream Device Trip Time:',
                          value: '${_upstreamTripTime.toStringAsFixed(3)} s',
                          icon: Icons.timer,
                          iconColor: Colors.orange,
                        ),
                        SizedBox(height: 8),
                        ResultItem(
                          label: 'Time Margin:',
                          value: '${_marginTime.toStringAsFixed(3)} s',
                          icon: Icons.compare_arrows,
                          iconColor: _isCoordinated ? Colors.green : Colors.red,
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Text(
                          'Coordination Recommendations:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildRecommendations(),
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
                        'About Protection Coordination',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Protection coordination ensures that the protective device closest to the fault operates first, providing:',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      BenefitItem(
                        text: 'Selective tripping to minimize outage area',
                        icon: Icons.precision_manufacturing,
                        iconColor: Colors.blue,
                      ),
                      BenefitItem(
                        text: 'Faster fault clearing to reduce equipment damage',
                        icon: Icons.speed,
                        iconColor: Colors.green,
                      ),
                      BenefitItem(
                        text: 'Backup protection in case primary protection fails',
                        icon: Icons.security,
                        iconColor: Colors.orange,
                      ),
                      BenefitItem(
                        text: 'Compliance with codes and standards (NEC, IEEE)',
                        icon: Icons.gavel,
                        iconColor: Colors.purple,
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Show protection coordination learning resources
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
  
  Widget _buildRecommendations() {
    if (_isCoordinated) {
      return Text(
        'The protection scheme is properly coordinated. No changes needed.',
        style: TextStyle(color: Colors.green.shade700),
      );
    } else {
      List<Widget> recommendations = [];
      
      if (_marginTime < 0) {
        // Upstream device trips faster than downstream
        recommendations.add(
          Text('• Increase the upstream device size or add intentional time delay',
            style: TextStyle(color: Colors.red.shade700),
          ),
        );
        recommendations.add(
          Text('• Decrease the downstream device size for faster operation',
            style: TextStyle(color: Colors.red.shade700),
          ),
        );
      } else {
        // Margin is positive but insufficient
        recommendations.add(
          Text('• Increase the upstream device time delay by at least ${(_getRequiredMargin(_downstreamTypeController.text, _upstreamTypeController.text) - _marginTime).toStringAsFixed(2)} seconds',
            style: TextStyle(color: Colors.orange.shade700),
          ),
        );
      }
      
      recommendations.add(
        Text('• Consider changing device types for better coordination',
          style: TextStyle(color: Colors.blue.shade700),
        ),
      );
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations,
      );
    }
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