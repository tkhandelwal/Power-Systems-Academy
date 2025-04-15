// lib/screens/pe_exam_prep_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PEExamPrepScreen extends StatelessWidget {
  const PEExamPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PE Power Exam Prep'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              _showExamInfoDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(context),
            SizedBox(height: 24),
            
            // Study Plan Section
            Text(
              'Study Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildStudyPlanCard(context),
            SizedBox(height: 24),
            
            // Practice Section
            Text(
              'Practice & Test Yourself',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildPracticeCard(context),
            SizedBox(height: 24),
            
            // References Section
            Text(
              'Essential References',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildReferencesCard(context),
            SizedBox(height: 24),
            
            // Calculators Section
            Text(
              'Calculation Tools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildCalculatorsCard(context),
            SizedBox(height: 24),
            
            // Exam Day Tips
            Text(
              'Exam Day Preparation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildExamDayTipsCard(context),
            SizedBox(height: 32),
            
            // Motivation
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: Colors.amber.shade800,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Youve Got This!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'With consistent study and practice, youll be well-prepared for exam day.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard(BuildContext context) {
    // Calculate a mock exam date 120 days from now
    final examDate = DateTime.now().add(Duration(days: 120));
    final daysRemaining = examDate.difference(DateTime.now()).inDays;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Color.fromARGB(255, 63, 81, 181),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PE Power Exam',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Comprehensive Preparation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExamInfoColumn(
                  'Exam Date',
                  DateFormat('MMM d, y').format(examDate),
                  Icons.calendar_today,
                ),
                _buildExamInfoColumn(
                  'Days Left',
                  daysRemaining.toString(),
                  Icons.hourglass_bottom,
                ),
                _buildExamInfoColumn(
                  'Completion',
                  '35%',
                  Icons.pie_chart,
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.35,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to detailed progress screen
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View Detailed Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExamInfoColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudyPlanCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.calendar_month,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              'Personalized Study Plan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Create and follow a customized study schedule'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/pe_exam_planner');
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: Icon(
                Icons.track_changes,
                color: Colors.orange,
              ),
            ),
            title: Text(
              'Topic Progress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Track your mastery of exam topics'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to topic progress screen
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: Icon(
                Icons.timer,
                color: Colors.green,
              ),
            ),
            title: Text(
              'Study Timer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Track your study hours with built-in timer'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to study timer screen
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPracticeCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(
                Icons.quiz,
                color: Colors.blue,
              ),
            ),
            title: Text(
              'Practice Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Test your knowledge with 500+ practice questions'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/practice_questions');
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.2),
              child: Icon(
                Icons.assignment,
                color: Colors.purple,
              ),
            ),
            title: Text(
              'Mock Exams',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Simulate exam conditions with full-length practice tests'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to mock exams screen
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Icon(
                Icons.flash_on,
                color: Colors.teal,
              ),
            ),
            title: Text(
              'Quick Quizzes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Short, focused quizzes by topic'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to quick quizzes screen
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildReferencesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.2),
              child: Icon(
                Icons.book,
                color: Colors.red,
              ),
            ),
            title: Text(
              'NEC Reference Guide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Quick access to key NEC articles for the exam'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/nec_reference');
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withOpacity(0.2),
              child: Icon(
                Icons.functions,
                color: Colors.indigo,
              ),
            ),
            title: Text(
              'Formula Reference',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Essential formulas for power engineering'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/power_formulas');
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber.withOpacity(0.2),
              child: Icon(
                Icons.library_books,
                color: Colors.amber,
              ),
            ),
            title: Text(
              'Study Materials',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Comprehensive study guides and references'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/study_materials');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalculatorsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.brown.withOpacity(0.2),
              child: Icon(
                Icons.calculate,
                color: Colors.brown,
              ),
            ),
            title: Text(
              'PE Power Calculators',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Specialized calculators for power engineering problems'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/calculators');
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: Icon(
                Icons.history_edu,
                color: Colors.green,
              ),
            ),
            title: Text(
              'Calculation Examples',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('Step-by-step walkthroughs of complex calculations'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to calculation examples screen
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildExamDayTipsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Colors.blue.shade800,
                ),
                SizedBox(width: 8),
                Text(
                  'Exam Day Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildExamTip(
              '1. Prepare your reference materials',
              'Tab and highlight important sections in your references for quick access.',
            ),
            _buildExamTip(
              '2. Know your calculator',
              'Practice with the calculator youll use on exam day until you can use it efficiently.',
            ),
            _buildExamTip(
              '3. Manage your time',
              'Spend no more than 6 minutes per question to complete all 80 questions in 8 hours.',
            ),
            _buildExamTip(
              '4. Answer easy questions first',
              'Skip difficult questions and return to them after completing the easier ones.',
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Navigate to complete exam day guide
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade800),
                minimumSize: Size(double.infinity, 44),
              ),
              child: Text('View Complete Exam Guide'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExamTip(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showExamInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About the PE Power Exam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Principles and Practice of Engineering (PE) Power exam is designed for engineers who have gained at least four years of post-college work experience in their chosen engineering discipline.',
            ),
            SizedBox(height: 16),
            Text(
              'Exam Format:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• 8-hour exam with 80 questions'),
            Text('• 40 questions in the morning session'),
            Text('• 40 questions in the afternoon session'),
            Text('• Open book - you can bring approved references'),
            SizedBox(height: 16),
            Text(
              'Exam Topics:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• Circuit Analysis'),
            Text('• Measurement and Instrumentation'),
            Text('• Rotating Machines'),
            Text('• Electromagnetic Devices'),
            Text('• Transmission and Distribution'),
            Text('• Protection'),
            Text('• General Power Engineering'),
            Text('• Codes and Standards'),
            SizedBox(height: 16),
            Text(
              'This app is designed to help you prepare for all aspects of the exam with practice questions, references, and calculation tools.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to NCEES website
            },
            child: Text('Official NCEES Info'),
          ),
        ],
      ),
    );
  }
}