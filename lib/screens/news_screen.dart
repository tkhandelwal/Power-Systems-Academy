import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems = [
    {
      'title': 'NCEES Updates PE Power Exam Specifications',
      'source': 'Engineering News Daily',
      'date': 'April 8, 2025',
      'summary': 'The National Council of Examiners for Engineering and Surveying (NCEES) has announced updates to the PE Power exam specifications for 2026.',
      'imageUrl': 'assets/images/news1.jpg',
    },
    {
      'title': 'New IEEE Standard for Distributed Energy Resources',
      'source': 'Power Engineering International',
      'date': 'April 5, 2025',
      'summary': 'The IEEE has released a new standard for interconnection and interoperability of distributed energy resources with associated electric power systems interfaces.',
      'imageUrl': 'assets/images/news2.jpg',
    },
    {
      'title': 'Study Reveals Top Challenges for Power PE Exam Takers',
      'source': 'Engineering Education Journal',
      'date': 'April 1, 2025',
      'summary': 'A recent study of PE exam candidates identified protection coordination and short circuit analysis as the most challenging topics for test takers.',
      'imageUrl': 'assets/images/news3.jpg',
    },
    {
      'title': 'Department of Energy Announces Grid Modernization Initiative',
      'source': 'Federal Energy News',
      'date': 'March 28, 2025',
      'summary': 'The U.S. Department of Energy has announced a new USD 3 billion initiative to modernize the nations electrical grid infrastructure.',
      'imageUrl': 'assets/images/news4.jpg',
    },
    {
      'title': 'NEC 2026 Preview: Major Changes Coming for Power Engineers',
      'source': 'Code Compliance Weekly',
      'date': 'March 25, 2025',
      'summary': 'The next edition of the National Electrical Code will include significant updates to requirements for renewable energy systems and energy storage.',
      'imageUrl': 'assets/images/news5.jpg',
    },
  ];

  NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News & Updates'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Show filters
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final news = newsItems[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            news['source'],
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '• ${news['date']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        news['summary'],
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Share news
                            },
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 16),
                                SizedBox(width: 4),
                                Text('Share'),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Read more
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
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
        },
      ),
    );
  }
}