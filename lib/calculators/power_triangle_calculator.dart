// lib/calculators/power_triangle_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:powersystemsacademy/widgets/base_calculator_widget.dart';
import 'package:powersystemsacademy/widgets/educational_content_widget.dart';

class PowerTriangleCalculatorScreen extends StatefulWidget {
  const PowerTriangleCalculatorScreen({super.key});

  @override
  PowerTriangleCalculatorScreenState createState() => PowerTriangleCalculatorScreenState();
}

class PowerTriangleCalculatorScreenState extends State<PowerTriangleCalculatorScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Input parameters
  String _inputType = 'active_reactive'; // active_reactive, active_apparent, reactive_apparent
  
  // Controllers for input fields
  final TextEditingController _activePowerController = TextEditingController();
  final TextEditingController _reactivePowerController = TextEditingController();
  final TextEditingController _apparentPowerController = TextEditingController();
  final TextEditingController _powerFactorController = TextEditingController();
  
  // Results
  double _resultActivePower = 0.0;
  double _resultReactivePower = 0.0;
  double _resultApparentPower = 0.0;
  double _resultPowerFactor = 0.0;
  double _resultPhaseAngle = 0.0;
  
  bool _hasCalculated = false;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _activePowerController.dispose();
    _reactivePowerController.dispose();
    _apparentPowerController.dispose();
    _powerFactorController.dispose();
    super.dispose();
  }
  
  // Get current input values as a map for saving
  Map<String, dynamic> get currentInputs {
    if (!_hasCalculated) return {};
    
    return {
      'input_type': _inputType,
      'active_power': _activePowerController.text,
      'reactive_power': _reactivePowerController.text,
      'apparent_power': _apparentPowerController.text,
      'power_factor': _powerFactorController.text,
    };
  }
  
  void _calculatePowerTriangle() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      // Simulate calculation delay for UI feedback
      Future.delayed(Duration(milliseconds: 300), () {
        try {
          // Parse inputs based on selected input type
          switch (_inputType) {
            case 'active_reactive':
              // P and Q given
              double p = double.parse(_activePowerController.text);
              double q = double.parse(_reactivePowerController.text);
              
              // Calculate S and power factor
              _resultActivePower = p;
              _resultReactivePower = q;
              _resultApparentPower = sqrt(p * p + q * q);
              _resultPhaseAngle = atan2(q, p) * (180 / pi); // Convert to degrees
              _resultPowerFactor = cos(atan2(q, p));
              break;
              
            case 'active_apparent':
              // P and S given
              double p = double.parse(_activePowerController.text);
              double s = double.parse(_apparentPowerController.text);
              
              // Check if P <= S
              if (p > s) {
                throw Exception('Active power cannot be greater than apparent power');
              }
              
              // Calculate Q and power factor
              _resultActivePower = p;
              _resultApparentPower = s;
              _resultReactivePower = sqrt(s * s - p * p);
              _resultPhaseAngle = acos(p / s) * (180 / pi); // Convert to degrees
              _resultPowerFactor = p / s;
              break;
              
            case 'reactive_apparent':
              // Q and S given
              double q = double.parse(_reactivePowerController.text);
              double s = double.parse(_apparentPowerController.text);
              
              // Check if Q <= S
              if (q > s) {
                throw Exception('Reactive power cannot be greater than apparent power');
              }
              
              // Calculate P and power factor
              _resultReactivePower = q;
              _resultApparentPower = s;
              _resultActivePower = sqrt(s * s - q * q);
              _resultPhaseAngle = asin(q / s) * (180 / pi); // Convert to degrees
              _resultPowerFactor = _resultActivePower / s;
              break;
              
            case 'active_pf':
              // P and PF given
              double p = double.parse(_activePowerController.text);
              double pf = double.parse(_powerFactorController.text);
              
              // Check if PF <= 1
              if (pf > 1) {
                throw Exception('Power factor cannot be greater than 1');
              }
              
              // Calculate S, Q, and phase angle
              _resultActivePower = p;
              _resultPowerFactor = pf;
              _resultApparentPower = p / pf;
              _resultPhaseAngle = acos(pf) * (180 / pi); // Convert to degrees
              _resultReactivePower = _resultApparentPower * sin(_resultPhaseAngle * (pi / 180));
              break;
              
            case 'apparent_pf':
              // S and PF given
              double s = double.parse(_apparentPowerController.text);
              double pf = double.parse(_powerFactorController.text);
              
              // Check if PF <= 1
              if (pf > 1) {
                throw Exception('Power factor cannot be greater than 1');
              }
              
              // Calculate P, Q, and phase angle
              _resultApparentPower = s;
              _resultPowerFactor = pf;
              _resultActivePower = s * pf;
              _resultPhaseAngle = acos(pf) * (180 / pi); // Convert to degrees
              _resultReactivePower = s * sin(_resultPhaseAngle * (pi / 180));
              break;
          }
          
          setState(() {
            _hasCalculated = true;
            _isCalculating = false;
          });
        } catch (e) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          
          setState(() {
            _isCalculating = false;
          });
        }
      });
    }
  }
  
  void _resetCalculator() {
    setState(() {
      _activePowerController.clear();
      _reactivePowerController.clear();
      _apparentPowerController.clear();
      _powerFactorController.clear();
      _hasCalculated = false;
    });
  }
  
  // Input section widget
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _inputType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem(
              value: 'active_reactive',
              child: Text('Active (P) and Reactive (Q) Power'),
            ),
            DropdownMenuItem(
              value: 'active_apparent',
              child: Text('Active (P) and Apparent (S) Power'),
            ),
            DropdownMenuItem(
              value: 'reactive_apparent',
              child: Text('Reactive (Q) and Apparent (S) Power'),
            ),
            DropdownMenuItem(
              value: 'active_pf',
              child: Text('Active Power (P) and Power Factor'),
            ),
            DropdownMenuItem(
              value: 'apparent_pf',
              child: Text('Apparent Power (S) and Power Factor'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _inputType = value!;
            });
          },
        ),
        SizedBox(height: 16),
        
        // Dynamic input fields based on selected input type
        // Active Power (P)
        if (_inputType.contains('active')) ...[
          TextFormField(
            controller: _activePowerController,
            decoration: InputDecoration(
              labelText: 'Active Power (P) in kW',
              hintText: 'e.g., 100',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.power),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter active power';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) < 0) {
                return 'Power cannot be negative';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
        
        // Reactive Power (Q)
        if (_inputType.contains('reactive')) ...[
          TextFormField(
            controller: _reactivePowerController,
            decoration: InputDecoration(
              labelText: 'Reactive Power (Q) in kVAR',
              hintText: 'e.g., 75',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.power_input),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter reactive power';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) < 0) {
                return 'Power cannot be negative';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
        
        // Apparent Power (S)
        if (_inputType.contains('apparent')) ...[
          TextFormField(
            controller: _apparentPowerController,
            decoration: InputDecoration(
              labelText: 'Apparent Power (S) in kVA',
              hintText: 'e.g., 125',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.show_chart),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter apparent power';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Apparent power must be positive';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
        
        // Power Factor (PF)
        if (_inputType.contains('pf')) ...[
          TextFormField(
            controller: _powerFactorController,
            decoration: InputDecoration(
              labelText: 'Power Factor (0 to 1)',
              hintText: 'e.g., 0.8',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.speed),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter power factor';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              double pf = double.parse(value);
              if (pf <= 0 || pf > 1) {
                return 'Power factor must be between 0 and 1';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
      ],
    );
  }
  
  // Results section widget
  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calculate,
              color: Colors.blue,
            ),
            SizedBox(width: 8),
            Text(
              'Power Triangle Results',
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
          label: 'Active Power (P):',
          value: '${_resultActivePower.toStringAsFixed(2)} kW',
          icon: Icons.power,
          iconColor: Colors.green,
        ),
        SizedBox(height: 8),
        ResultItem(
          label: 'Reactive Power (Q):',
          value: '${_resultReactivePower.toStringAsFixed(2)} kVAR',
          icon: Icons.power_input,
          iconColor: Colors.blue,
        ),
        SizedBox(height: 8),
        ResultItem(
          label: 'Apparent Power (S):',
          value: '${_resultApparentPower.toStringAsFixed(2)} kVA',
          icon: Icons.show_chart,
          iconColor: Colors.purple,
        ),
        SizedBox(height: 8),
        ResultItem(
          label: 'Power Factor:',
          value: _resultPowerFactor.toStringAsFixed(3),
          icon: Icons.speed,
          iconColor: Colors.orange,
        ),
        SizedBox(height: 8),
        ResultItem(
          label: 'Phase Angle:',
          value: '${_resultPhaseAngle.toStringAsFixed(2)}°',
          icon: Icons.rotate_right,
          iconColor: Colors.red,
        ),
        SizedBox(height: 16),
        
        // Add power triangle diagram
        _buildPowerTriangleDiagram(),
        
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // In a real app, this would export to PDF, etc.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Results saved to your device'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: Icon(Icons.save_alt),
              label: Text('Save Results'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Custom power triangle diagram
  Widget _buildPowerTriangleDiagram() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CustomPaint(
        painter: PowerTrianglePainter(
          activePower: _resultActivePower,
          reactivePower: _resultReactivePower,
          apparentPower: _resultApparentPower,
          phaseAngle: _resultPhaseAngle,
        ),
        child: Container(),
      ),
    );
  }
  
  // Educational content widget
  Widget _buildEducationalContent() {
    return EducationalContent(
      title: 'Understanding the Power Triangle',
      sections: [
        EducationalSection(
          title: 'Power Triangle Basics',
          content: 'The power triangle is a graphical representation of the relationship between active power (P), reactive power (Q), and apparent power (S) in AC electrical systems. It helps visualize how these components relate to each other and to power factor.',
        ),
        EducationalSection(
          title: 'Components of the Power Triangle',
          content: 'Active Power (P) represents the actual power consumed to do useful work, measured in watts (W) or kilowatts (kW). Reactive Power (Q) is the power that flows back and forth between the source and load without doing useful work, measured in volt-amperes reactive (VAR) or kilovolt-amperes reactive (kVAR). Apparent Power (S) is the total power in the circuit, measured in volt-amperes (VA) or kilovolt-amperes (kVA).',
        ),
        EducationalSection(
          title: 'Power Factor',
          content: 'The power factor is the ratio of active power to apparent power (P/S). It represents the efficiency of electrical power utilization in the system. A power factor of 1.0 (or 100%) indicates that all power is being used effectively to produce work, while a lower power factor indicates inefficient power usage.',
        ),
      ],
      relatedFormulaReference: 'In the power triangle, S² = P² + Q², Power Factor = cos φ = P/S, and φ = tan⁻¹(Q/P)',
      examTip: 'The PE Power exam often includes questions requiring calculation of missing power triangle components. Remember that improving power factor reduces reactive power demand and overall system losses.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseCalculatorScreen(
      title: 'Power Triangle Calculator',
      calculatorType: 'power_triangle',
      icon: Icons.show_chart,
      iconColor: Colors.purple,
      inputSection: _buildInputSection(),
      resultSection: _buildResultsSection(),
      educationalContent: _buildEducationalContent(),
      onCalculate: _calculatePowerTriangle,
      onReset: _resetCalculator,
      showResults: _hasCalculated,
      isCalculating: _isCalculating,
      currentInputs: currentInputs,
      formKey: _formKey,
    );
  }
}

// Power Triangle Painter for the custom diagram
class PowerTrianglePainter extends CustomPainter {
  final double activePower;
  final double reactivePower;
  final double apparentPower;
  final double phaseAngle;
  
  PowerTrianglePainter({
    required this.activePower,
    required this.reactivePower,
    required this.apparentPower,
    required this.phaseAngle,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final Paint activePowerPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final Paint reactivePowerPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final Paint apparentPowerPaint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    final Paint anglePaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Calculate scale factor to fit the triangle within the canvas
    final maxPower = max(apparentPower, max(activePower, reactivePower));
    final scale = (size.width * 0.7) / maxPower;
    
    // Origin point (left side of the triangle)
    final Offset origin = Offset(size.width * 0.15, size.height * 0.5);
    
    // Calculate triangle points
    final Offset activePoint = Offset(origin.dx + activePower * scale, origin.dy);
    final Offset reactivePoint = Offset(activePoint.dx, activePoint.dy - reactivePower * scale);
    
    // Draw the triangle
    final Path trianglePath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(activePoint.dx, activePoint.dy)
      ..lineTo(reactivePoint.dx, reactivePoint.dy)
      ..close();
    
    // Draw angle arc
    final Path anglePath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..arcTo(
        Rect.fromCenter(
          center: origin,
          width: 40,
          height: 40,
        ),
        0,
        -phaseAngle * (pi / 180),
        false,
      )
      ..lineTo(origin.dx, origin.dy)
      ..close();
    
    // Draw the components
    canvas.drawPath(anglePath, anglePaint);
    canvas.drawLine(origin, activePoint, activePowerPaint);
    canvas.drawLine(activePoint, reactivePoint, reactivePowerPaint);
    canvas.drawLine(origin, reactivePoint, apparentPowerPaint);
    
    // Add labels
    _drawLabel(canvas, 'P = ${activePower.toStringAsFixed(1)} kW', Offset(origin.dx + activePower * scale / 2, origin.dy + 20), Colors.green);
    _drawLabel(canvas, 'Q = ${reactivePower.toStringAsFixed(1)} kVAR', Offset(activePoint.dx + 10, origin.dy - reactivePower * scale / 2), Colors.blue);
    _drawLabel(canvas, 'S = ${apparentPower.toStringAsFixed(1)} kVA', Offset(origin.dx + apparentPower * scale / 3, origin.dy - apparentPower * scale / 3), Colors.purple);
    _drawLabel(canvas, 'φ = ${phaseAngle.toStringAsFixed(1)}°', Offset(origin.dx + 30, origin.dy - 10), Colors.red);
  }
  
  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
  
  @override
  bool shouldRepaint(PowerTrianglePainter oldDelegate) {
    return oldDelegate.activePower != activePower ||
           oldDelegate.reactivePower != reactivePower ||
           oldDelegate.apparentPower != apparentPower ||
           oldDelegate.phaseAngle != phaseAngle;
  }
}

// Result item widget for displaying individual results
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