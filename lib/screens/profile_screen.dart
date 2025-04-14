import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(),
            SizedBox(height: 24),
            Text(
              'Study Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            StudyProgressCard(),
            SizedBox(height: 24),
            Text(
              'Exam Preparations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ExamPreparationCard(),
            SizedBox(height: 24),
            Text(
              'Study History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            StudyHistoryCard(),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                'JS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'John Smith',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Power Engineer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text('PE Candidate'),
                        backgroundColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Chip(
                        label: Text('Active'),
                        backgroundColor: Colors.green.withAlpha((0.2 * 255).round()),
                        labelStyle: TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyProgressCard extends StatelessWidget {
  final List<Map<String, dynamic>> topicProgress = [
    {
      'topic': 'Power System Analysis',
      'progress': 75,
      'color': Colors.blue,
    },
    {
      'topic': 'Electrical Equipment',
      'progress': 60,
      'color': Colors.green,
    },
    {
      'topic': 'Power Transmission',
      'progress': 45,
      'color': Colors.orange,
    },
    {
      'topic': 'Power Distribution',
      'progress': 30,
      'color': Colors.purple,
    },
    {
      'topic': 'Codes & Standards',
      'progress': 20,
      'color': Colors.red,
    },
  ];

  StudyProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress: 46%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.46,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
              minHeight: 10,
            ),
            SizedBox(height: 24),
            Text(
              'Topic Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...topicProgress.map((topic) => TopicProgressBar(
                  topic: topic['topic'],
                  progress: topic['progress'],
                  color: topic['color'],
                )),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // View detailed analytics
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text('View Detailed Analytics'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicProgressBar extends StatelessWidget {
  final String topic;
  final int progress;
  final Color color;

  const TopicProgressBar({
    super.key,
    required this.topic,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic),
              Text('$progress%'),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

class ExamPreparationCard extends StatelessWidget {
  const ExamPreparationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exam Date: June 26, 2025',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Change date
                  },
                  child: Text('Change'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Days Remaining: 75',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Study Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Weekly Study Goal'),
              subtitle: Text('20 hours / week'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Edit study goal
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Practice Exams Scheduled'),
              subtitle: Text('2 of 5 completed'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // View practice exam schedule
              },
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // View study plan
                },
                icon: Icon(Icons.calendar_month),
                label: Text('View Study Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> studyHistory = [
    {
      'activity': 'Completed Practice Quiz',
      'topic': 'Power System Analysis',
      'date': 'Today',
      'score': '80%',
      'icon': Icons.quiz,
      'color': Colors.blue,
    },
    {
      'activity': 'Watched Video Lecture',
      'topic': 'Power Factor Correction',
      'date': 'Yesterday',
      'duration': '45 min',
      'icon': Icons.video_library,
      'color': Colors.red,
    },
    {
      'activity': 'Used Calculator',
      'topic': 'Three-Phase Power',
      'date': 'Yesterday',
      'icon': Icons.calculate,
      'color': Colors.green,
    },
    {
      'activity': 'Read Reference Guide',
      'topic': 'NEC Code Requirements',
      'date': '2 days ago',
      'duration': '1 hr 20 min',
      'icon': Icons.menu_book,
      'color': Colors.amber,
    },
    {
      'activity': 'Took Mock Exam',
      'topic': 'Full Length Practice',
      'date': '1 week ago',
      'score': '72%',
      'icon': Icons.assignment,
      'color': Colors.purple,
    },
  ];

  StudyHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all history
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...studyHistory.map((activity) => StudyActivityTile(
                  activity: activity,
                )),
          ],
        ),
      ),
    );
  }
}

class StudyActivityTile extends StatelessWidget {
  final Map<String, dynamic> activity;

  const StudyActivityTile({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: activity['color'].withOpacity(0.2),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['activity'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity['topic'],
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      activity['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8),
                    if (activity.containsKey('score'))
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity['score'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (activity.containsKey('duration'))
                      Text(
                        activity['duration'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}