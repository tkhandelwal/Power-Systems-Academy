// lib/screens/topic_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:powersystemsacademy/models/exam_content_models.dart';
import 'package:powersystemsacademy/services/exam_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final Topic topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  TopicDetailScreenState createState() => TopicDetailScreenState();
}

class TopicDetailScreenState extends State<TopicDetailScreen> {
  final ExamService _examService = ExamService();
  bool _isLoading = true;
  List<Subtopic> _subtopics = [];
  final Map<int, List<Content>> _contentMap = {};
  final Map<int, bool> _expandedSubtopics = {};

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
      // Load subtopics
      _subtopics = await _examService.getSubtopicsForTopic(widget.topic.id);
      
      // Load content for each subtopic
      for (var subtopic in _subtopics) {
        List<Content> content = await _examService.getContentForSubtopic(subtopic.id);
        _contentMap[subtopic.id] = content;
        
        // Initialize expanded state (start collapsed)
        _expandedSubtopics[subtopic.id] = false;
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading topic content: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _toggleSubtopic(int subtopicId) {
    setState(() {
      _expandedSubtopics[subtopicId] = !(_expandedSubtopics[subtopicId] ?? false);
    });
  }
  
  void _markContentCompleted(Content content) async {
    // Toggle the completion status in the UI
    setState(() {
      content.isCompleted = !content.isCompleted;
    });
    
    // Update the database
    await _examService.markContentAsCompleted(content.id, content.isCompleted);
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content.isCompleted ? 'Marked as completed' : 'Marked as incomplete'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        actions: [
          IconButton(
            icon: Icon(Icons.quiz),
            onPressed: () {
              // Navigate to practice questions for this topic
              Navigator.pushNamed(
                context,
                '/practice_questions',
                arguments: {
                  'topicId': widget.topic.id,
                  'topicName': widget.topic.name,
                },
              );
            },
            tooltip: 'Practice Questions',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Topic overview card
                _buildTopicOverviewCard(),
                
                // Subtopics and content
                Expanded(
                  child: _subtopics.isEmpty
                      ? Center(
                          child: Text('No content available for this topic yet'),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _subtopics.length,
                          itemBuilder: (context, index) {
                            return _buildSubtopicCard(_subtopics[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/practice_questions',
            arguments: {
              'topicId': widget.topic.id,
              'topicName': widget.topic.name,
              'isQuiz': true,
            },
          );
        },
        icon: Icon(Icons.quiz),
        label: Text('Take Quiz'),
      ),
    );
  }
  
  Widget _buildTopicOverviewCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.book,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Progress: ${widget.topic.progressPercentage}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: widget.topic.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 12),
            Text(
              widget.topic.description ?? 'Essential topic for the PE Power exam',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to topic resources
                    _showTopicResourcesDialog();
                  },
                  icon: Icon(Icons.book),
                  label: Text('Study Resources'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubtopicCard(Subtopic subtopic) {
    final isExpanded = _expandedSubtopics[subtopic.id] ?? false;
    final contentList = _contentMap[subtopic.id] ?? [];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Subtopic header
          ListTile(
            title: Text(
              subtopic.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(subtopic.description ?? 'Important subtopic for the PE Exam'),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => _toggleSubtopic(subtopic.id),
          ),
          
          // Expanded content
          if (isExpanded) ...[
            Divider(),
            contentList.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No content available for this subtopic yet'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: contentList.length,
                    itemBuilder: (context, index) {
                      return _buildContentItem(contentList[index]);
                    },
                  ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildContentItem(Content content) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion checkbox
          Checkbox(
            value: content.isCompleted,
            onChanged: (value) {
              _markContentCompleted(content);
            },
          ),
          SizedBox(width: 8),
          // Content info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content.contentBody,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Show full content
                        _showContentDetailDialog(content);
                      },
                      child: Text('Read More'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showContentDetailDialog(Content content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(content.contentBody),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _markContentCompleted(content);
                    },
                    icon: Icon(content.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                    label: Text(content.isCompleted ? 'Mark as Incomplete' : 'Mark as Completed'),
                  ),
                ],
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
  
  void _showTopicResourcesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Study Resources'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended References:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildResourceItem(
                'Power System Analysis',
                'by John J. Grainger and William D. Stevenson Jr.',
                Icons.menu_book,
              ),
              _buildResourceItem(
                'IEEE Std 399',
                'IEEE Recommended Practice for Power Systems Analysis',
                Icons.description,
              ),
              _buildResourceItem(
                'NFPA 70: National Electrical Code',
                '2023 Edition',
                Icons.book,
              ),
              SizedBox(height: 16),
              Text(
                'Online Resources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildResourceItem(
                'NCEES PE Power Reference Handbook',
                'Official reference for the exam',
                Icons.book_online,
              ),
              _buildResourceItem(
                'IEEE Power & Energy Society',
                'Educational resources and standards',
                Icons.language,
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
  
  Widget _buildResourceItem(String title, String description, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}