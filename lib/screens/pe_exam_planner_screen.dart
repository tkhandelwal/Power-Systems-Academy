// lib/screens/pe_exam_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:powersystemsacademy/services/exam_service.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';

class PEExamPlannerScreen extends StatefulWidget {
  const PEExamPlannerScreen({super.key});

  @override
  PEExamPlannerScreenState createState() => PEExamPlannerScreenState();
}

class PEExamPlannerScreenState extends State<PEExamPlannerScreen> {
  final TextEditingController _studyHoursController = TextEditingController(text: '20');
  final ExamService _examService = ExamService();
  
  DateTime? _examDate;
  List<Topic> _topics = [];
  List<StudyPlanItem> _studyPlan = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _studyHoursController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load topics
      _topics = await _examService.getTopics();
      
      // Load exam plan
      var examPlan = await _examService.getExamPlan();
      if (examPlan != null && examPlan['exam_date'] != null) {
        _examDate = DateTime.parse(examPlan['exam_date']);
        _studyHoursController.text = examPlan['weekly_study_hours'].toString();
        
        // Generate study plan based on saved data
        _generateStudyPlan();
      }
      
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
  
  void _selectExamDate() async {
    // Show date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    );
    
    if (picked != null && picked != _examDate) {
      setState(() {
        _examDate = picked;
      });
    }
  }
  
  void _generateStudyPlan() {
    if (_examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an exam date first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Parse weekly study hours
    int weeklyStudyHours;
    try {
      weeklyStudyHours = int.parse(_studyHoursController.text);
      if (weeklyStudyHours <= 0) throw FormatException();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid number of study hours'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Save exam plan to database
    _examService.saveExamPlan(_examDate!, weeklyStudyHours);
      
    // Calculate weeks available for study
    final DateTime now = DateTime.now();
    final int daysUntilExam = _examDate!.difference(now).inDays;
    final int weeksUntilExam = (daysUntilExam / 7).ceil();
    
    if (weeksUntilExam <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exam date must be in the future'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
      
    // Clear existing plan
    _studyPlan = [];
      
    // Calculate total study hours available
    final int totalStudyHours = weeksUntilExam * weeklyStudyHours;
      
    // Allocate hours proportionally to topics based on relevance/size
    int totalHoursAllocated = 0;
      
    for (final topic in _topics) {
      // Calculate importance factor (1-2 range) - could be based on exam weighting
      double importanceFactor = 1.0;
      if (topic.name.contains('Power System') || topic.name.contains('Protection')) {
        importanceFactor = 1.5; // More important topics
      }
        
      // Calculate hours for this topic (weighted by importance)
      final int topicHours = ((totalStudyHours * importanceFactor) / _topics.length).round();
      totalHoursAllocated += topicHours;
      
      // Calculate weeks needed for this topic
      final int weeksForTopic = (topicHours / weeklyStudyHours).ceil();
      
      // Create study plan item
      _studyPlan.add(
        StudyPlanItem(
          topic: topic.name,
          totalHours: topicHours,
          weeksAllocated: weeksForTopic,
          subtopics: [], // Will be populated below
        ),
      );
        
      // Load subtopics for each topic and add to study plan
      _loadSubtopicsForTopic(topic, _studyPlan.length - 1);
    }
  
    // Verify that all hours are allocated (with possible small rounding differences)
    if ((totalHoursAllocated - totalStudyHours).abs() > totalStudyHours * 0.05) {
      // If more than 5% difference between allocated and total available hours
      print('Warning: Allocated hours ($totalHoursAllocated) significantly differ from total available hours ($totalStudyHours)');
      
      // Adjust last topic to match total hours if needed
      if (_studyPlan.isNotEmpty) {
        int lastTopicHours = _studyPlan.last.totalHours;
        int adjustment = totalStudyHours - (totalHoursAllocated - lastTopicHours);
        
        if (adjustment > 0) {
          setState(() {
            _studyPlan.last.totalHours = adjustment;
            _studyPlan.last.weeksAllocated = (adjustment / weeklyStudyHours).ceil();
          });
        }
      }
    }
      
    // Refresh UI
    setState(() {});
  }
  
  Future<void> _loadSubtopicsForTopic(Topic topic, int planIndex) async {
    try {
      List<Subtopic> subtopics = await _examService.getSubtopicsForTopic(topic.id);
      
      setState(() {
        _studyPlan[planIndex].subtopics = subtopics.map((s) => s.name).toList();
      });
    } catch (e) {
      print('Error loading subtopics for topic ${topic.name}: $e');
    }
  }
  
  void _exportStudyPlan() {
    // In a real app, this would export the study plan to PDF, share it, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Study plan exported successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PE Exam Study Planner'),
        actions: [
          if (_studyPlan.isNotEmpty)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _exportStudyPlan,
              tooltip: 'Export Study Plan',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExamInfoCard(),
                  SizedBox(height: 16),
                  if (_studyPlan.isNotEmpty) ...[
                    Text(
                      'Your Personalized Study Plan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ..._buildStudyPlanWidgets(),
                  ] else ...[
                    _buildTopicsOverviewCard(),
                  ],
                ],
              ),
            ),
    );
  }
  
  Widget _buildExamInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _selectExamDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Exam Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Select your exam date',
                ),
                child: _examDate == null
                    ? Text('Select your exam date')
                    : Text(DateFormat('MMMM d, yyyy').format(_examDate!)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _studyHoursController,
              decoration: InputDecoration(
                labelText: 'Weekly Study Hours',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.access_time),
                helperText: 'Recommended: 15-25 hours per week',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            if (_examDate != null) ...[
              Text(
                'Days Until Exam: ${_examDate!.difference(DateTime.now()).inDays}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _generateStudyPlan,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Generate Study Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopicsOverviewCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PE Power Exam Topics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(_topics.length, (index) {
              final topic = _topics[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(topic.name),
                    ),
                    Text(
                      '${topic.progressPercentage}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the PE Power Exam:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• 80 questions (40 in morning session, 40 in afternoon)'),
                  Text('• 8-hour exam (4 hours morning, 4 hours afternoon)'),
                  Text('• Open book - you can bring approved references'),
                  Text('• Passing score varies by state and administration'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildStudyPlanWidgets() {
    List<Widget> widgets = [];
    
    // Calculate total weeks
    int totalWeeks = 0;
    for (final item in _studyPlan) {
      totalWeeks += item.weeksAllocated;
    }
    
    // Generate start and end dates for each topic
    DateTime startDate = DateTime.now();
    
    for (int i = 0; i < _studyPlan.length; i++) {
      final item = _studyPlan[i];
      
      // Calculate end date for this topic
      final endDate = startDate.add(Duration(days: item.weeksAllocated * 7 - 1));
      
      widgets.add(
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.topic,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${item.totalHours} hrs',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Study Focus:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                if (item.subtopics.isEmpty)
                  Text('Loading subtopics...')
                else
                  ...item.subtopics.map((subtopic) => Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(subtopic),
                        ),
                      ],
                    ),
                  )),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Would navigate to related study materials
                          Navigator.pushNamed(context, '/study_materials');
                        },
                        icon: Icon(Icons.book),
                        label: Text('Study Materials'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Would navigate to practice questions for this topic
                          Navigator.pushNamed(
                            context, 
                            '/practice_questions',
                            arguments: {'topicName': item.topic},
                          );
                        },
                        icon: Icon(Icons.quiz),
                        label: Text('Practice Questions'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      
      widgets.add(SizedBox(height: 16));
      
      // Update start date for next topic
      startDate = endDate.add(Duration(days: 1));
    }
    
    return widgets;
  }
}

class StudyPlanItem {
  final String topic;
  int totalHours;
  int weeksAllocated;
  List<String> subtopics;
  
  StudyPlanItem({
    required this.topic,
    required this.totalHours,
    required this.weeksAllocated,
    required this.subtopics,
  });
}