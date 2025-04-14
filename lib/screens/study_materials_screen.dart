import 'package:flutter/material.dart';

class StudyMaterialsScreen extends StatelessWidget {
  const StudyMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Study Materials'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Topics'),
              Tab(text: 'Practice Questions'),
              Tab(text: 'Flashcards'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TopicsTab(),
            PracticeQuestionsTab(),
            FlashcardsTab(),
          ],
        ),
      ),
    );
  }
}

class TopicsTab extends StatelessWidget {
  final List<Map<String, dynamic>> topics = [
    {
      'title': 'Power System Analysis',
      'subtopics': [
        'Load Flow Studies',
        'Fault Analysis',
        'Power System Stability',
        'Economic Operation',
        'Power System Protection',
      ],
      'progress': 75,
    },
    {
      'title': 'Electrical Equipment',
      'subtopics': [
        'Transformers',
        'Motors & Generators',
        'Circuit Breakers',
        'Switchgear',
        'Protective Relays',
      ],
      'progress': 60,
    },
    {
      'title': 'Power Transmission',
      'subtopics': [
        'Transmission Line Parameters',
        'Corona Effect',
        'Insulator Design',
        'HVDC Transmission',
        'Surge Impedance Loading',
      ],
      'progress': 45,
    },
    {
      'title': 'Power Distribution',
      'subtopics': [
        'Distribution System Types',
        'Voltage Regulation',
        'System Reliability',
        'Power Quality',
        'Circuit Protection',
      ],
      'progress': 30,
    },
    {
      'title': 'Electrical Codes & Standards',
      'subtopics': [
        'National Electrical Code (NEC)',
        'IEEE Standards',
        'NFPA 70E',
        'NESC',
        'ANSI Standards',
      ],
      'progress': 20,
    },
  ];

  TopicsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              topic['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: topic['progress'] / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text('${topic['progress']}% Complete'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subtopics:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...List.generate(
                      topic['subtopics'].length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.book, size: 16),
                            SizedBox(width: 8),
                            Text(topic['subtopics'][i]),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text('Start Studying'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text('Practice Questions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PracticeQuestionsTab extends StatelessWidget {
  const PracticeQuestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Questions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
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
                    'Quick Quiz',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Take a 10-question quiz on any topic to test your knowledge',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text('Start Quiz'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Question Banks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                QuestionBankCard(
                  title: 'Power System Analysis',
                  questionCount: 250,
                  completedCount: 75,
                  difficulty: 'Mixed',
                ),
                SizedBox(height: 12),
                QuestionBankCard(
                  title: 'Electrical Equipment',
                  questionCount: 200,
                  completedCount: 40,
                  difficulty: 'Mixed',
                ),
                SizedBox(height: 12),
                QuestionBankCard(
                  title: 'Power Transmission',
                  questionCount: 180,
                  completedCount: 30,
                  difficulty: 'Mixed',
                ),
                SizedBox(height: 12),
                QuestionBankCard(
                  title: 'Power Distribution',
                  questionCount: 150,
                  completedCount: 20,
                  difficulty: 'Mixed',
                ),
                SizedBox(height: 12),
                QuestionBankCard(
                  title: 'Electrical Codes & Standards',
                  questionCount: 120,
                  completedCount: 10,
                  difficulty: 'Mixed',
                ),
                SizedBox(height: 12),
                QuestionBankCard(
                  title: 'Full Practice Exams',
                  questionCount: 480,
                  completedCount: 0,
                  difficulty: 'Hard',
                  isLocked: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionBankCard extends StatelessWidget {
  final String title;
  final int questionCount;
  final int completedCount;
  final String difficulty;
  final bool isLocked;

  const QuestionBankCard({
    super.key,
    required this.title,
    required this.questionCount,
    required this.completedCount,
    required this.difficulty,
    this.isLocked = false,
  });

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
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLocked)
                  Icon(Icons.lock, color: Colors.orange)
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$questionCount Questions',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Difficulty: $difficulty',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: completedCount / questionCount,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '$completedCount of $questionCount completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLocked ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text('Practice'),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isLocked ? null : () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('Review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardsTab extends StatelessWidget {
  final List<Map<String, dynamic>> flashcardDecks = [
    {
      'title': 'Power System Fundamentals',
      'cards': 120,
      'mastered': 45,
      'color': Colors.blue,
    },
    {
      'title': 'Key Formulas',
      'cards': 85,
      'mastered': 30,
      'color': Colors.green,
    },
    {
      'title': 'Electrical Equipment',
      'cards': 100,
      'mastered': 25,
      'color': Colors.orange,
    },
    {
      'title': 'Protection Systems',
      'cards': 75,
      'mastered': 15,
      'color': Colors.purple,
    },
    {
      'title': 'Code Requirements',
      'cards': 90,
      'mastered': 10,
      'color': Colors.red,
    },
  ];

  FlashcardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flashcard Decks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: flashcardDecks.length,
              itemBuilder: (context, index) {
                final deck = flashcardDecks[index];
                return FlashcardDeckCard(
                  title: deck['title'],
                  cardCount: deck['cards'],
                  masteredCount: deck['mastered'],
                  color: deck['color'],
                  onTap: () {
                    // Navigate to flashcard deck
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardDeckCard extends StatelessWidget {
  final String title;
  final int cardCount;
  final int masteredCount;
  final Color color;
  final VoidCallback onTap;

  const FlashcardDeckCard({
    super.key,
    required this.title,
    required this.cardCount,
    required this.masteredCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (masteredCount / cardCount * 100).round();
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.style,
                  color: color,
                  size: 36,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                '$cardCount cards',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: masteredCount / cardCount,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              SizedBox(height: 4),
              Text(
                '$percentage% Mastered',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: Size(double.infinity, 40),
                ),
                child: Text('Study Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}