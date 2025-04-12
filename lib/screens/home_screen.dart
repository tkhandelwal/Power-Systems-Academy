import 'package:flutter/material.dart';
import 'package:powersystemsacademy/widgets/countdown_card.dart';
import 'package:powersystemsacademy/widgets/progress_card.dart';
import 'package:powersystemsacademy/widgets/feature_card.dart';
import 'package:powersystemsacademy/widgets/recent_activity_card.dart';
import 'package:powersystemsacademy/models/recent_activity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RecentActivity> recentActivities = [
    RecentActivity(
      title: 'Completed Practice Quiz',
      description: 'Power Transmission - 80% Score',
      time: 'Today, 10:30 AM',
      iconData: Icons.assignment_turned_in,
      iconColor: Colors.blue,
    ),
    RecentActivity(
      title: 'Watched Video Lecture',
      description: 'Introduction to Power Factor Correction',
      time: 'Yesterday, 3:15 PM',
      iconData: Icons.video_library,
      iconColor: Colors.red,
    ),
    RecentActivity(
      title: 'Used Calculator',
      description: 'Three-Phase Power Calculator',
      time: 'Yesterday, 1:45 PM',
      iconData: Icons.calculate,
      iconColor: Colors.green,
    ),
    RecentActivity(
      title: 'Read Reference Guide',
      description: 'NEC Code Requirements for Power Systems',
      time: '2 days ago, 5:20 PM',
      iconData: Icons.book,
      iconColor: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PE Power Prep'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16.0),
            
            // Countdown and Progress Row
            Row(
              children: [
                Expanded(
                  child: CountdownCard(
                    daysRemaining: 75,
                    onSetDate: () {
                      // Show date picker
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ProgressCard(
                    progressPercentage: 65,
                    onViewProgress: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.0),
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16.0),
            
            // Feature Cards Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                FeatureCard(
                  title: 'Practice Questions',
                  description: 'Test your knowledge',
                  iconData: Icons.quiz,
                  onTap: () => Navigator.pushNamed(context, '/study_materials'),
                ),
                FeatureCard(
                  title: 'Calculators',
                  description: 'Power engineering tools',
                  iconData: Icons.calculate,
                  onTap: () => Navigator.pushNamed(context, '/calculators'),
                ),
                FeatureCard(
                  title: 'Video Lectures',
                  description: 'Learn from experts',
                  iconData: Icons.video_library,
                  onTap: () => Navigator.pushNamed(context, '/learning_resources'),
                ),
                FeatureCard(
                  title: 'Formula Sheets',
                  description: 'Quick reference',
                  iconData: Icons.functions,
                  onTap: () => Navigator.pushNamed(context, '/learning_resources'),
                ),
                FeatureCard(
                  title: 'Community',
                  description: 'Connect with others',
                  iconData: Icons.people,
                  onTap: () => Navigator.pushNamed(context, '/community'),
                ),
                FeatureCard(
                  title: 'News & Updates',
                  description: 'Stay informed',
                  iconData: Icons.newspaper,
                  onTap: () => Navigator.pushNamed(context, '/news'),
                ),
              ],
            ),
            
            SizedBox(height: 24.0),
            RecentActivityCard(activities: recentActivities),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculators',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, '/study_materials');
              break;
            case 2:
              Navigator.pushNamed(context, '/calculators');
              break;
            case 3:
              Navigator.pushNamed(context, '/learning_resources');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'PE Power Prep',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Study Materials'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/study_materials');
            },
          ),
          ListTile(
            leading: Icon(Icons.calculate),
            title: Text('Calculators'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/calculators');
            },
          ),
          ListTile(
            leading: Icon(Icons.video_library),
            title: Text('Learning Resources'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/learning_resources');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Community'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/community');
            },
          ),
          ListTile(
            leading: Icon(Icons.newspaper),
            title: Text('News & Updates'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/news');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}