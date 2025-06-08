// lib/widgets/base_calculator_widget.dart
import 'package:flutter/material.dart';
import 'package:powersystemsacademy/services/calculator_service.dart';

/// Base widget for calculator screens to maintain consistent UI and functionality
class BaseCalculatorScreen extends StatefulWidget {
  final String title;
  final String calculatorType;
  final IconData icon;
  final Color iconColor;
  final Widget inputSection;
  final Widget resultSection;
  final Widget? educationalContent;
  final VoidCallback onCalculate;
  final VoidCallback? onReset;
  final bool showResults;
  final bool isCalculating;
  final Map<String, dynamic> currentInputs;
  final GlobalKey<FormState> formKey;

  const BaseCalculatorScreen({
    super.key,
    required this.title,
    required this.calculatorType,
    required this.icon,
    this.iconColor = Colors.blue,
    required this.inputSection,
    required this.resultSection,
    this.educationalContent,
    required this.onCalculate,
    this.onReset,
    required this.showResults,
    this.isCalculating = false,
    required this.currentInputs,
    required this.formKey,
  });

  @override
  BaseCalculatorScreenState createState() => BaseCalculatorScreenState();
}

class BaseCalculatorScreenState extends State<BaseCalculatorScreen> {
  final TextEditingController _saveNameController = TextEditingController();
  final CalculatorService _calculatorService = CalculatorService();
  List<Map<String, dynamic>> _savedCalculations = [];
  bool _isLoadingCalculations = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedCalculations();
    
    // Log usage
    _calculatorService.logCalculatorUsage(widget.calculatorType);
  }
  
  @override
  void dispose() {
    _saveNameController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedCalculations() async {
    setState(() {
      _isLoadingCalculations = true;
    });
    
    try {
      final saved = await _calculatorService.getSavedCalculations(widget.calculatorType);
      setState(() {
        _savedCalculations = saved;
      });
    } catch (e) {
      // Handle error
      print('Error loading saved calculations: $e');
    } finally {
      setState(() {
        _isLoadingCalculations = false;
      });
    }
  }
  
  void _saveCurrentCalculation() {
    if (widget.currentInputs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No inputs to save'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Calculation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _saveNameController,
              decoration: InputDecoration(
                labelText: 'Calculation Name',
                hintText: 'e.g., Project A Transformer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLength: 50,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_saveNameController.text.isEmpty) {
                return;
              }
              
              await _calculatorService.saveCalculation(
                calculatorType: widget.calculatorType,
                name: _saveNameController.text,
                inputs: widget.currentInputs,
              );
              
              _saveNameController.clear();
              Navigator.of(context).pop();
              
              // Refresh saved calculations
              _loadSavedCalculations();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calculation saved successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showSavedCalculations() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Calculations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: _isLoadingCalculations
                      ? Center(child: CircularProgressIndicator())
                      : _savedCalculations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_alt,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No saved calculations yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Save your calculations for quick access',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _savedCalculations.length,
                              itemBuilder: (context, index) {
                                final calculation = _savedCalculations[index];
                                final timestamp = DateTime.parse(calculation['timestamp']);
                                final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                                
                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(
                                      calculation['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text('Saved on $formattedDate'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            await _calculatorService.deleteSavedCalculation(
                                              widget.calculatorType, 
                                              index
                                            );
                                            _loadSavedCalculations();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Calculation deleted'),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          tooltip: 'Delete',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.play_arrow),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            // Load calculation inputs (would need to be implemented in parent widget)
                                            Navigator.of(context).maybePop(calculation['inputs']);
                                          },
                                          tooltip: 'Load',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About ${widget.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.educationalContent ?? Container(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: widget.showResults ? _saveCurrentCalculation : null,
            tooltip: 'Save Calculation',
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: () {
              _showSavedCalculations();
            },
            tooltip: 'Saved Calculations',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
            tooltip: 'Information',
          ),
        ],
      ),
      body: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: widget.iconColor.withOpacity(0.2),
                            child: Icon(
                              widget.icon,
                              color: widget.iconColor,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Input Parameters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      widget.inputSection,
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.isCalculating ? null : widget.onCalculate,
                              icon: widget.isCalculating 
                                  ? SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      )
                                    ) 
                                  : Icon(Icons.calculate),
                              label: Text(
                                widget.isCalculating ? 'Calculating...' : 'Calculate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          if (widget.onReset != null) ...[
                            SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: widget.onReset,
                              icon: Icon(Icons.refresh),
                              label: Text('Reset'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Results Section
              if (widget.showResults)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: widget.resultSection,
                  ),
                ),
                
              SizedBox(height: 16),
              
              // Educational Content Section
              if (widget.educationalContent != null)
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
                          'Educational Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        widget.educationalContent!,
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