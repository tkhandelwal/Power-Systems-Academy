// lib/screens/pe_exam_prep_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powersystemsacademy/services/exam_service.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';

class PEExamPrepScreen extends StatefulWidget {
  const PEExamPrepScreen({super.key});

  @override
  PEExamPrepScreenState createState() => PEExamPrepScreenState();
}

class PEExamPrepScreenState extends State<PEExamPrepScreen> {
  final ExamService _examService = ExamService();
  List<Topic> _topics = [];
  Map<String, dynamic>? _examPlan;
  List<StudyActivity> _recentActivities = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load topics
      _topics = await _examService.getTopics();
      
      // Load exam plan
      _examPlan = await _examService.getExamPlan();
      
      // Load recent activities
      _recentActivities = await _examService.getRecentActivities(5);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exam data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
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
                    
                    // Topics Section
                    Text(
                      'Study Topics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildTopicsGrid(context),
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
                              'You\'ve Got This!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'With consistent study and practice, you\'ll be well-prepared for exam day.',
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
            ),
    );
  }
  
  Widget _buildHeaderCard(BuildContext context) {
    // Calculate days remaining if exam date is set
    int daysRemaining = 0;
    DateTime? examDate;
    
    if (_examPlan != null && _examPlan!['exam_date'] != null) {
      examDate = DateTime.parse(_examPlan!['exam_date']);
      daysRemaining = examDate.difference(DateTime.now()).inDays;
    } else {
      // Default exam date 120 days from now if not set
      examDate = DateTime.now().add(Duration(days: 120));
      daysRemaining = 120;
    }
    
    // Calculate overall progress
    int overallProgress = 0;
    if (_topics.isNotEmpty) {
      int totalProgress = _topics.fold(0, (sum, topic) => sum + topic.progressPercentage);
      overallProgress = (totalProgress / _topics.length).round();
    }
    
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
                  '$overallProgress%',
                  Icons.pie_chart,
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
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
              Navigator.pushNamed(context, '/study_materials');
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
              // Navigate to study timer screen or show dialog with timer
              _showStudyTimerDialog(context);
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
              // Navigate to a new MockExamsScreen (to be implemented)
              _showUnderDevelopmentDialog(context, 'Mock Exams');
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
              // Show dialog to select topic for quick quiz
              _showQuizTopicSelectionDialog(context);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopicsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to topic detail screen (to be implemented)
              _navigateToTopicDetail(topic);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic icon or image
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Topic title
                  Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // Topic description
                  Text(
                    topic.description ?? 'Essential topic for the PE Power exam',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  // Progress indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${topic.progressPercentage}%',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: topic.progressPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              _showUnderDevelopmentDialog(context, 'Calculation Examples');
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
              'Practice with the calculator you\'ll use on exam day until you can use it efficiently.',
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
                // Show full exam day guide
                _showExamDayGuideDialog(context);
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
              // Open URL to NCEES website (would need url_launcher package)
              // launchUrl(Uri.parse('https://ncees.org/engineering/pe/electrical-and-computer/'));
            },
            child: Text('Official NCEES Info'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToTopicDetail(Topic topic) {
    // Navigate to topic detail screen
    Navigator.pushNamed(
      context,
      '/topic_detail',
      arguments: {'topic': topic},
    );
  }
  
  void _showQuizTopicSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Topic for Quick Quiz'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    _topics[index].name.substring(0, 1),
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
                title: Text(_topics[index].name),
                subtitle: Text('${_topics[index].progressPercentage}% complete'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to practice questions with topic filter
                  Navigator.pushNamed(
                    context, 
                    '/practice_questions',
                    arguments: {'topicId': _topics[index].id, 'topicName': _topics[index].name, 'isQuiz': true},
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showStudyTimerDialog(BuildContext context) {
    int minutes = 30; // Default timer value
    bool timerRunning = false;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Study Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set a focused study session',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: timerRunning ? null : () {
                        setState(() {
                          if (minutes > 5) minutes -= 5;
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$minutes min',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: timerRunning ? null : () {
                        setState(() {
                          minutes += 5;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(timerRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(timerRunning ? 'Stop Timer' : 'Start Timer'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        timerRunning = !timerRunning;
                      });
                      
                      if (timerRunning) {
                        // Start a timer (simplified - would need a real timer implementation)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Timer started for $minutes minutes'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        
                        // In a real implementation, you would start a timer here
                        // and update the UI accordingly
                      } else {
                        // Stop the timer
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Timer stopped'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
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
            ],
          );
        },
      ),
    );
  }
  
  void _showExamDayGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exam Day Complete Guide'),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 400),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildExamDayGuideSection(
                'Before Exam Day',
                [
                  'Get a good night\'s sleep for several days before the exam',
                  'Prepare all your reference materials, organizing them for quick access',
                  'Pack your calculator, pencils, erasers, and other allowed items',
                  'Confirm your exam location and plan your route',
                  'Prepare a light meal or snacks for exam day',
                ]
              ),
              SizedBox(height: 12),
              _buildExamDayGuideSection(
                'Morning of the Exam',
                [
                  'Wake up early and have a balanced breakfast',
                  'Arrive at the exam location at least 30 minutes early',
                  'Bring your exam admission ticket and ID',
                  'Bring only approved materials into the exam room',
                  'Take deep breaths and stay calm',
                ]
              ),
              SizedBox(height: 12),
              _buildExamDayGuideSection(
                'During the Exam',
                [
                  'Read each question carefully before answering',
                  'Budget your time - approximately 6 minutes per question',
                  'Answer the easiest questions first',
                  'Mark questions you want to revisit',
                  'Take short breaks to clear your mind if needed',
                  'Double-check your answers if time permits',
                ]
              ),
              SizedBox(height: 12),
              _buildExamDayGuideSection(
                'Break Between Sessions',
                [
                  'Use this time to relax and recharge',
                  'Have a light lunch to maintain energy',
                  'Review any challenging topics if needed',
                  'Stretch and move around to stay alert',
                ]
              ),
              SizedBox(height: 12),
              _buildExamDayGuideSection(
                'After the Exam',
                [
                  'Relax and reward yourself for completing the exam',
                  'Avoid excessive analysis of questions and answers',
                  'Results typically arrive in 8-10 weeks',
                ]
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExamDayGuideSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 8),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(point)),
            ],
          ),
        )),
      ],
    );
  }
  
  void _showUnderDevelopmentDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              '$feature feature is under development',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This feature will be available in an upcoming update.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}