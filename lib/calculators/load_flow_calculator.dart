// lib/calculators/load_flow_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';

// Import the complex number utility class
import 'package:powersystemsacademy/utils/complex.dart';

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
  
  // Bus types - making this final as suggested
  final List<String> _busTypes = ['Slack', 'PV', 'PQ'];
  
  // Dynamic list of buses with their properties
  final List<Map<String, dynamic>> _buses = [];
  
  // Matrix for line impedances
  final List<List<TextEditingController>> _lineImpedanceControllers = [];
  
  // Results
  final List<Map<String, dynamic>> _busResults = [];
  final List<Map<String, dynamic>> _lineResults = [];
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
      try {
        // Parse input parameters
        int busCount = int.parse(_busCountController.text);
        double slackBusVoltage = double.parse(_slackBusVoltageController.text);
        double tolerance = double.parse(_toleranceController.text);
        int maxIterations = int.parse(_maxIterationsController.text);
        
        // Create arrays for bus data
        List<Map<String, dynamic>> busData = [];
        for (var bus in _buses) {
          busData.add({
            'number': bus['number'],
            'type': bus['type'],
            'voltage': double.parse(bus['voltage'].text),
            'angle': double.parse(bus['angle'].text) * (pi / 180), // Convert to radians
            'activePower': double.parse(bus['activePower'].text),
            'reactivePower': double.parse(bus['reactivePower'].text),
          });
        }
        
        // Create admittance matrix
        List<List<Complex>> Y = List.generate(
          busCount, 
          (i) => List.generate(
            busCount, 
            (j) => Complex(0, 0)
          )
        );
        
        // Fill admittance matrix from line impedance values
        for (int i = 0; i < busCount; i++) {
          for (int j = 0; j < busCount; j++) {
            if (i != j) {
              double impedance = double.parse(_lineImpedanceControllers[i][j].text);
              if (impedance > 0) {
                // Convert impedance to admittance (Y = 1/Z)
                Complex admittance = Complex(1, 0) / Complex(0, impedance);
                Y[i][j] = -admittance; // Off-diagonal elements
                
                // Add to diagonal elements
                Y[i][i] = Y[i][i] + admittance;
                Y[j][j] = Y[j][j] + admittance;
              }
            }
          }
        }
        
        // Newton-Raphson load flow algorithm
        int iterations = 0;
        bool converged = false;
        double maxMismatch = double.infinity;
        
        // Arrays to store calculated values
        List<double> calculatedV = List.generate(busCount, (i) => busData[i]['voltage']);
        List<double> calculatedTheta = List.generate(busCount, (i) => busData[i]['angle']);
        List<double> calculatedP = List.generate(busCount, (i) => 0.0);
        List<double> calculatedQ = List.generate(busCount, (i) => 0.0);
        
        while (!converged && iterations < maxIterations) {
          // Calculate power mismatches
          List<double> deltaPQ = [];
          
          // Calculate P and Q at each bus
          for (int i = 0; i < busCount; i++) {
            calculatedP[i] = 0;
            calculatedQ[i] = 0;
            
            for (int j = 0; j < busCount; j++) {
              Complex Vi = Complex.polar(calculatedV[i], calculatedTheta[i]);
              Complex Vj = Complex.polar(calculatedV[j], calculatedTheta[j]);
              Complex Yij = Y[i][j];
              
              Complex Sij = Vi * (Yij * Vj).conjugate();
              calculatedP[i] += Sij.real;
              calculatedQ[i] += Sij.imaginary;
            }
            
            // Add power mismatches for PV and PQ buses
            if (busData[i]['type'] != 'Slack') {
              // Active power mismatch (all buses except slack)
              double deltaP = busData[i]['activePower'] - calculatedP[i];
              deltaPQ.add(deltaP);
              
              // Reactive power mismatch (only PQ buses)
              if (busData[i]['type'] == 'PQ') {
                double deltaQ = busData[i]['reactivePower'] - calculatedQ[i];
                deltaPQ.add(deltaQ);
              }
            }
          }
          
          // Check for convergence
          maxMismatch = 0;
          for (double mismatch in deltaPQ) {
            maxMismatch = max(maxMismatch, mismatch.abs());
          }
          
          if (maxMismatch < tolerance) {
            converged = true;
            break;
          }
          
          // Calculate Jacobian matrix
          List<List<double>> J = _calculateJacobian(busData, Y, calculatedV, calculatedTheta);
          
          // Solve J * deltaX = deltaPQ using Gaussian elimination
          List<double> deltaX = _solveLinearSystem(J, deltaPQ);
          
          // Update voltage angles and magnitudes
          int index = 0;
          for (int i = 0; i < busCount; i++) {
            if (busData[i]['type'] != 'Slack') {
              // Update angle (all buses except slack)
              calculatedTheta[i] += deltaX[index++];
              
              // Update voltage magnitude (only PQ buses)
              if (busData[i]['type'] == 'PQ') {
                calculatedV[i] += deltaX[index++];
              }
            }
          }
          
          iterations++;
        }
        
        // Prepare results
        _busResults.clear();
        for (int i = 0; i < busCount; i++) {
          _busResults.add({
            'number': busData[i]['number'],
            'type': busData[i]['type'],
            'voltage': calculatedV[i].toStringAsFixed(4),
            'angle': (calculatedTheta[i] * (180 / pi)).toStringAsFixed(4), // Convert to degrees
            'activePower': calculatedP[i].toStringAsFixed(4),
            'reactivePower': calculatedQ[i].toStringAsFixed(4),
          });
        }
        
        // Calculate line flows
        _lineResults.clear();
        for (int i = 0; i < busCount; i++) {
          for (int j = i + 1; j < busCount; j++) {
            double impedance = double.parse(_lineImpedanceControllers[i][j].text);
            if (impedance > 0) {
              Complex Vi = Complex.polar(calculatedV[i], calculatedTheta[i]);
              Complex Vj = Complex.polar(calculatedV[j], calculatedTheta[j]);
              Complex Yij = Y[i][j];
              
              Complex Iij = (Vi - Vj) / Complex(0, impedance);
              Complex Sij = Vi * Iij.conjugate();
              Complex Sji = Vj * (-Iij).conjugate();
              
              double losses = (Sij.real + Sji.real).abs();
              
              _lineResults.add({
                'from': i + 1,
                'to': j + 1,
                'activePower': Sij.real.toStringAsFixed(4),
                'reactivePower': Sij.imaginary.toStringAsFixed(4),
                'current': Iij.magnitude.toStringAsFixed(4),
                'losses': losses.toStringAsFixed(4),
              });
            }
          }
        }
        
        // Update state to show results
        setState(() {
          _hasCalculated = true;
          _iterationCount = iterations.toString();
          _hasConverged = converged;
        });
      } catch (e) {
        // Show error message if calculation fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in calculation: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Helper method to calculate Jacobian matrix
  List<List<double>> _calculateJacobian(
    List<Map<String, dynamic>> busData,
    List<List<Complex>> Y,
    List<double> V,
    List<double> theta
  ) {
    int busCount = busData.length;
    
    // Determine Jacobian size based on number of equations
    int pqCount = 0;  // Number of PQ buses
    int pvCount = 0;  // Number of PV buses
    
    for (var bus in busData) {
      if (bus['type'] == 'PQ') pqCount++;
      if (bus['type'] == 'PV') pvCount++;
    }
    
    int jacobianSize = (pqCount * 2) + pvCount;  // 2 equations per PQ bus, 1 per PV bus
    
    // Initialize Jacobian matrix
    List<List<double>> J = List.generate(
      jacobianSize, 
      (i) => List.generate(jacobianSize, (j) => 0.0)
    );
    
    // Counters for building the Jacobian
    int row = 0;
    
    // Each non-slack bus contributes rows to the Jacobian
    for (int i = 0; i < busCount; i++) {
      if (busData[i]['type'] == 'Slack') continue;
      
      int col = 0;
      
      // Calculate derivatives for active power equations (dP/dTheta and dP/dV)
      for (int j = 0; j < busCount; j++) {
        if (busData[j]['type'] == 'Slack') continue;
        
        // dP_i/dTheta_j
        if (i == j) {
          // Diagonal element for dP_i/dTheta_i
          double sum = 0.0;
          for (int k = 0; k < busCount; k++) {
            if (k != i) {
              Complex Yik = Y[i][k];
              double Vk = V[k];
              double thetak = theta[k];
              double thetaik = theta[i] - thetak;
              sum += V[i] * Vk * (Yik.real * sin(thetaik) - Yik.imaginary * cos(thetaik));
            }
          }
          J[row][col] = -sum;
        } else {
          // Off-diagonal element for dP_i/dTheta_j
          Complex Yij = Y[i][j];
          double thetaij = theta[i] - theta[j];
          J[row][col] = V[i] * V[j] * (Yij.real * sin(thetaij) - Yij.imaginary * cos(thetaij));
        }
        
        col++;
        
        // dP_i/dV_j (only if j is PQ bus)
        if (busData[j]['type'] == 'PQ') {
          if (i == j) {
            // Diagonal element for dP_i/dV_i
            double sum = 0.0;
            for (int k = 0; k < busCount; k++) {
              if (k != i) {
                Complex Yik = Y[i][k];
                double Vk = V[k];
                double thetaik = theta[i] - theta[k];
                sum += Vk * (Yik.real * cos(thetaik) + Yik.imaginary * sin(thetaik));
              }
            }
            J[row][col] = 2 * V[i] * Y[i][i].real + sum;
          } else {
            // Off-diagonal element for dP_i/dV_j
            Complex Yij = Y[i][j];
            double thetaij = theta[i] - theta[j];
            J[row][col] = V[i] * (Yij.real * cos(thetaij) + Yij.imaginary * sin(thetaij));
          }
          col++;
        }
      }
      
      row++;
      
      // Calculate derivatives for reactive power equations (dQ/dTheta and dQ/dV)
      // Only for PQ buses
      if (busData[i]['type'] == 'PQ') {
        col = 0;
        
        for (int j = 0; j < busCount; j++) {
          if (busData[j]['type'] == 'Slack') continue;
          
          // dQ_i/dTheta_j
          if (i == j) {
            // Diagonal element for dQ_i/dTheta_i
            double sum = 0.0;
            for (int k = 0; k < busCount; k++) {
              if (k != i) {
                Complex Yik = Y[i][k];
                double Vk = V[k];
                double thetaik = theta[i] - theta[k];
                sum += V[i] * Vk * (Yik.real * cos(thetaik) + Yik.imaginary * sin(thetaik));
              }
            }
            J[row][col] = sum;
          } else {
            // Off-diagonal element for dQ_i/dTheta_j
            Complex Yij = Y[i][j];
            double thetaij = theta[i] - theta[j];
            J[row][col] = -V[i] * V[j] * (Yij.real * cos(thetaij) + Yij.imaginary * sin(thetaij));
          }
          
          col++;
          
          // dQ_i/dV_j (only if j is PQ bus)
          if (busData[j]['type'] == 'PQ') {
            if (i == j) {
              // Diagonal element for dQ_i/dV_i
              double sum = 0.0;
              for (int k = 0; k < busCount; k++) {
                if (k != i) {
                  Complex Yik = Y[i][k];
                  double Vk = V[k];
                  double thetaik = theta[i] - theta[k];
                  sum += Vk * (Yik.real * sin(thetaik) - Yik.imaginary * cos(thetaik));
                }
              }
              J[row][col] = -2 * V[i] * Y[i][i].imaginary + sum;
            } else {
              // Off-diagonal element for dQ_i/dV_j
              Complex Yij = Y[i][j];
              double thetaij = theta[i] - theta[j];
              J[row][col] = V[i] * (Yij.real * sin(thetaij) - Yij.imaginary * cos(thetaij));
            }
            col++;
          }
        }
        
        row++;
      }
    }
    
    return J;
  }

  // Helper method to solve linear system using Gaussian elimination
  List<double> _solveLinearSystem(List<List<double>> A, List<double> b) {
    int n = b.length;
    if (n == 0) return [];
    
    // Make a copy of A and b to avoid modifying the originals
    List<List<double>> aug = List.generate(
      n, 
      (i) => List.generate(n + 1, (j) => j < n ? A[i][j] : b[i])
    );
    
    // Gaussian elimination with partial pivoting
    for (int i = 0; i < n; i++) {
      // Find pivot (largest element in column i)
      int maxRow = i;
      double maxVal = aug[i][i].abs();
      
      for (int k = i + 1; k < n; k++) {
        if (aug[k][i].abs() > maxVal) {
          maxRow = k;
          maxVal = aug[k][i].abs();
        }
      }
      
      // Swap rows if needed
      if (maxRow != i) {
        List<double> temp = aug[i];
        aug[i] = aug[maxRow];
        aug[maxRow] = temp;
      }
      
      // Check for singular matrix
      if (aug[i][i].abs() < 1e-10) {
        // Add a small value to diagonal to avoid division by zero
        aug[i][i] = 1e-10;
      }
      
      // Eliminate below
      for (int k = i + 1; k < n; k++) {
        double factor = aug[k][i] / aug[i][i];
        
        for (int j = i; j <= n; j++) {
          aug[k][j] -= factor * aug[i][j];
        }
      }
    }
    
    // Back substitution
    List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = aug[i][n];
      
      for (int j = i + 1; j < n; j++) {
        x[i] -= aug[i][j] * x[j];
      }
      
      x[i] /= aug[i][i];
    }
    
    return x;
  }
  
  void _updateBusCount() {
    if (_formKey.currentState!.validate()) {
      int count = int.parse(_busCountController.text);
      if (count >= 2 && count <= 10) {
        setState(() {
          _initializeBuses(count);
          _hasCalculated = false;
        });
      }
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