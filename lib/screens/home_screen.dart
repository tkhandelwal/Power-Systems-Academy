// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powersystemsacademy/main.dart';
import 'package:powersystemsacademy/widgets/countdown_card.dart';
import 'package:powersystemsacademy/widgets/progress_card.dart';
import 'package:powersystemsacademy/widgets/feature_card.dart';
import 'package:powersystemsacademy/widgets/recent_activity_card.dart';
import 'package:powersystemsacademy/models/recent_activity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

@override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Animation controller for the welcome card
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with flexible space
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode, 
                  color: Colors.white
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'PE Power Prep',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          primaryColor,
                        ],
                      ),
                    ),
                  ),
                  // Bottom gradient shadow for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card with animation
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                'JS',
                                style: TextStyle(
                                  fontSize: 20,
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
                                    'Welcome back, John!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Ready to continue your exam prep?',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Countdown and Progress Row
                  Row(
                    children: [
                      Expanded(
                        child: CountdownCard(
                          daysRemaining: 75,
                          onSetDate: () {
                            _showDatePicker(context);
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
                  
                  SizedBox(height: 24),
                  
                  // Tab navigation for quick access
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[700],
                      tabs: [
                        Tab(text: 'Study'),
                        Tab(text: 'Tools'),
                        Tab(text: 'Community'),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Tab content
                  SizedBox(
                    height: 220,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Study Tab
                        _buildStudyTab(),
                        
                        // Tools Tab
                        _buildToolsTab(),
                        
                        // Community Tab
                        _buildCommunityTab(),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Recent Activity Section
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  RecentActivityCard(activities: recentActivities),
                  
                  SizedBox(height: 24),
                  
                  // Tips and Motivation Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: Colors.amber[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tip of the Day',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'When studying protection schemes, focus on understanding the principles behind coordination rather than memorizing specific settings.',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Show more tips
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.amber[900],
                              ),
                              child: Text('More Tips'),
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
        ],
      ),
      drawer: buildDrawer(context),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
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
  
  // Study tab content
  Widget _buildStudyTab() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      children: [
        FeatureCard(
          title: 'Practice Questions',
          description: 'Test your knowledge',
          iconData: Icons.quiz,
          onTap: () => Navigator.pushNamed(context, '/study_materials'),
        ),
        FeatureCard(
          title: 'Flashcards',
          description: 'Quick study aids',
          iconData: Icons.style,
          onTap: () => Navigator.pushNamed(context, '/study_materials'),
        ),
        FeatureCard(
          title: 'Video Lectures',
          description: 'Learn from experts',
          iconData: Icons.video_library,
          onTap: () => Navigator.pushNamed(context, '/learning_resources'),
        ),
        FeatureCard(
          title: 'Study Plan',
          description: 'Organized learning',
          iconData: Icons.calendar_today,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }
  
  // Tools tab content
  Widget _buildToolsTab() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      children: [
        FeatureCard(
          title: 'Calculators',
          description: 'Power engineering tools',
          iconData: Icons.calculate,
          onTap: () => Navigator.pushNamed(context, '/calculators'),
        ),
        FeatureCard(
          title: 'Formula Sheets',
          description: 'Quick reference',
          iconData: Icons.functions,
          onTap: () => Navigator.pushNamed(context, '/learning_resources'),
        ),
        FeatureCard(
          title: 'Code References',
          description: 'NEC and standards',
          iconData: Icons.book,
          onTap: () => Navigator.pushNamed(context, '/learning_resources'),
        ),
        FeatureCard(
          title: 'Unit Converter',
          description: 'Convert measurements',
          iconData: Icons.swap_horiz,
          onTap: () => _showComingSoonSnackBar(context),
        ),
      ],
    );
  }
  
  // Community tab content
  Widget _buildCommunityTab() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.0,
      mainAxisSpacing: 12.0,
      children: [
        FeatureCard(
          title: 'Discussion Forums',
          description: 'Connect with peers',
          iconData: Icons.forum,
          onTap: () => Navigator.pushNamed(context, '/community'),
        ),
        FeatureCard(
          title: 'Study Groups',
          description: 'Collaborative learning',
          iconData: Icons.people,
          onTap: () => Navigator.pushNamed(context, '/community'),
        ),
        FeatureCard(
          title: 'Ask Questions',
          description: 'Get expert answers',
          iconData: Icons.help,
          onTap: () => Navigator.pushNamed(context, '/community'),
        ),
        FeatureCard(
          title: 'News & Updates',
          description: 'Stay informed',
          iconData: Icons.newspaper,
          onTap: () => Navigator.pushNamed(context, '/news'),
        ),
      ],
    );
  }
  
  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 75)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        // Calculate days remaining and update state
        final daysRemaining = date.difference(DateTime.now()).inDays;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exam date set! $daysRemaining days remaining.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
  
  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header with app branding and user info
          UserAccountsDrawerHeader(
            accountName: Text(
              'John Smith',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text('PE Candidate'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'JS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          
          // Main navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerNavigationItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                DrawerNavigationItem(
                  title: 'Study Materials',
                  icon: Icons.book,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/study_materials');
                  },
                ),
                DrawerNavigationItem(
                  title: 'Calculators',
                  icon: Icons.calculate,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/calculators');
                  },
                ),
                DrawerNavigationItem(
                  title: 'Learning Resources',
                  icon: Icons.video_library,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/learning_resources');
                  },
                ),
                DrawerNavigationItem(
                  title: 'Community',
                  icon: Icons.people,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/community');
                  },
                ),
                DrawerNavigationItem(
                  title: 'News & Updates',
                  icon: Icons.newspaper,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/news');
                  },
                ),
                Divider(),
                DrawerNavigationItem(
                  title: 'Profile',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                DrawerNavigationItem(
                  title: 'Settings',
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          
          // App version info and logout button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Divider(),
                SizedBox(height: 8),
                Text(
                  'App Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show logout dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Log Out'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Implement logout logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Log Out'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom drawer navigation item widget for consistent styling
class DrawerNavigationItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  const DrawerNavigationItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: onTap,
      selectedTileColor: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}