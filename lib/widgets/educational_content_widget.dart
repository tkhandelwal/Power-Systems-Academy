// lib/widgets/educational_content_widget.dart
import 'package:flutter/material.dart';

/// A reusable widget for displaying educational content in calculators
class EducationalContent extends StatefulWidget {
  final String title;
  final List<EducationalSection> sections;
  final String? relatedFormulaReference;
  final String? examTip;
  final String? codeReference;

  const EducationalContent({
    super.key,
    required this.title,
    required this.sections,
    this.relatedFormulaReference,
    this.examTip,
    this.codeReference,
  });

  @override
  EducationalContentState createState() => EducationalContentState();
}

class EducationalContentState extends State<EducationalContent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and expand/collapse button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ],
        ),
        
        // Preview text when collapsed
        if (!_expanded)
          Text(
            'Tap to learn more about ${widget.title.toLowerCase()}',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          
        // Expanded content
        if (_expanded) ...[
          Divider(),
          ...widget.sections.map((section) => _buildSection(section)).toList(),
          
          // Related formula reference if provided
          if (widget.relatedFormulaReference != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.functions, color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Related Formulas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(widget.relatedFormulaReference!),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/power_formulas');
                      },
                      icon: Icon(Icons.open_in_new, size: 16),
                      label: Text('View Formula Reference'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Exam tip if provided
          if (widget.examTip != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'PE Exam Tip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(widget.examTip!),
                ],
              ),
            ),
          ],
          
          // Code reference if provided
          if (widget.codeReference != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.green.shade700, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Code Reference',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(widget.codeReference!),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/nec_reference');
                      },
                      icon: Icon(Icons.open_in_new, size: 16),
                      label: Text('View NEC Reference'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
  
  Widget _buildSection(EducationalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          if (section.title != null) ...[
            Text(
              section.title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
          ],
          
          // Section content
          Text(section.content),
          
          // Image if provided
          if (section.imagePath != null) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                section.imagePath!,
                fit: BoxFit.contain,
              ),
            ),
            if (section.imageCaption != null) ...[
              SizedBox(height: 4),
              Text(
                section.imageCaption!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Represents a section of educational content
class EducationalSection {
  final String? title;
  final String content;
  final String? imagePath;
  final String? imageCaption;

  EducationalSection({
    this.title,
    required this.content,
    this.imagePath,
    this.imageCaption,
  });
}