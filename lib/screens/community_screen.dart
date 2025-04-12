import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Community'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Discussion'),
              Tab(text: 'Study Groups'),
              Tab(text: 'Q&A'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Show search
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Create new post
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            DiscussionTab(),
            StudyGroupsTab(),
            QATab(),
          ],
        ),
      ),
    );
  }
}

class DiscussionTab extends StatelessWidget {
  final List<Map<String, dynamic>> discussions = [
    {
      'title': 'Tips for studying transmission line calculations?',
      'author': 'EngineerJane',
      'time': '2 hours ago',
      'replies': 12,
      'views': 45,
      'tags': ['Transmission', 'Study Tips'],
    },
    {
      'title': 'Best reference books for power system protection?',
      'author': 'PowerGuy87',
      'time': '5 hours ago',
      'replies': 8,
      'views': 32,
      'tags': ['Protection', 'Books'],
    },
    {
      'title': 'How important is the NEC for the PE exam?',
      'author': 'ElectricalNewbie',
      'time': '8 hours ago',
      'replies': 15,
      'views': 67,
      'tags': ['NEC', 'Codes'],
    },
    {
      'title': 'Struggling with short-circuit calculations',
      'author': 'CircuitMaster',
      'time': '1 day ago',
      'replies': 20,
      'views': 89,
      'tags': ['Calculations', 'Short Circuit'],
    },
    {
      'title': 'What calculators are allowed during the exam?',
      'author': 'TestPrepper',
      'time': '2 days ago',
      'replies': 14,
      'views': 120,
      'tags': ['Exam Rules', 'Calculators'],
    },
  ];

  DiscussionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: discussions.length,
      itemBuilder: (context, index) {
        final discussion = discussions[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discussion['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        discussion['author'][0],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      discussion['author'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '• ${discussion['time']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.message,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${discussion['replies']} replies',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${discussion['views']} views',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (discussion['tags'] as List).map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withAlpha(51), // 0.2 * 255 = 51
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StudyGroupsTab extends StatelessWidget {
  final List<Map<String, dynamic>> studyGroups = [
    {
      'name': 'Power Systems Study Circle',
      'members': 24,
      'focus': 'Power System Analysis',
      'meetings': 'Wednesdays, 7 PM EST',
      'isJoined': true,
    },
    {
      'name': 'NEC Code Group',
      'members': 18,
      'focus': 'Code Requirements',
      'meetings': 'Mondays, 6 PM EST',
      'isJoined': false,
    },
    {
      'name': 'Protection & Coordination Team',
      'members': 15,
      'focus': 'Protection Systems',
      'meetings': 'Tuesdays, 8 PM EST',
      'isJoined': false,
    },
    {
      'name': 'Weekend Power Engineers',
      'members': 32,
      'focus': 'General Exam Prep',
      'meetings': 'Saturdays, 10 AM EST',
      'isJoined': true,
    },
    {
      'name': 'Transmission Line Calculations',
      'members': 12,
      'focus': 'Transmission Systems',
      'meetings': 'Thursdays, 7:30 PM EST',
      'isJoined': false,
    },
  ];

  StudyGroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
padding: EdgeInsets.all(16.0),
      itemCount: studyGroups.length,
      itemBuilder: (context, index) {
        final group = studyGroups[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.0),
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
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        group['name'][0],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${group['members']} members',
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
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Focus: ${group['focus']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Meetings: ${group['meetings']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Join or view group
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: group['isJoined'] ? Colors.green : Theme.of(context).primaryColor,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text(group['isJoined'] ? 'View Group' : 'Join Group'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class QATab extends StatelessWidget {
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Whats the difference between selective coordination and cascading?',
      'askedBy': 'TechEngineer',
      'time': '1 day ago',
      'answers': 3,
      'solved': true,
    },
    {
      'question': 'How do you calculate fault current in an unbalanced system?',
      'askedBy': 'PowerStudent',
      'time': '2 days ago',
      'answers': 5,
      'solved': true,
    },
    {
      'question': 'What are the limitations of per-unit calculations?',
      'askedBy': 'ElectricalNewbie',
      'time': '3 days ago',
      'answers': 2,
      'solved': false,
    },
    {
      'question': 'How do you interpret negative sequence impedance?',
      'askedBy': 'CircuitMaster',
      'time': '5 days ago',
      'answers': 4,
      'solved': true,
    },
    {
      'question': 'When should you use ANSI vs IEC short circuit calculations?',
      'askedBy': 'StandardsGuru',
      'time': '1 week ago',
      'answers': 6,
      'solved': false,
    },
  ];

  QATab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: questions.length + 1, // +1 for the ask button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Ask Question button
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Show ask question dialog
              },
              icon: Icon(Icons.help),
              label: Text('Ask a Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          );
        }

        final questionIndex = index - 1;
        final question = questions[questionIndex];
        return Card(
          margin: EdgeInsets.only(bottom: 12.0),
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
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        question['askedBy'][0],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      question['askedBy'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '• ${question['time']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    if (question['solved'])
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Solved',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.question_answer,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${question['answers']} answers',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        // View question
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text('View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}