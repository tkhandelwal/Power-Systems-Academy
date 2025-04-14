import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _downloadOverWifi = true;
  String _selectedTheme = 'Blue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Edit Profile'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Edit profile
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Exam Date'),
                  subtitle: Text('June 26, 2025'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Change exam date
                  },
                ),
                ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Change Password'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Change password
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text('Notifications'),
                  subtitle: Text('Receive study reminders and updates'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Dark Mode'),
                  subtitle: Text('Enable dark theme'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
               SwitchListTile(
                  title: Text('Download Over Wi-Fi Only'),
                  subtitle: Text('Save mobile data'),
                  value: _downloadOverWifi,
                  onChanged: (value) {
                    setState(() {
                      _downloadOverWifi = value;
                    });
                  },
                ),
                ListTile(
                  title: Text('App Theme'),
                  subtitle: Text(_selectedTheme),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Show theme selection dialog
                    _showThemeSelectionDialog();
                  },
                ),
                ListTile(
                  title: Text('Clear Cache'),
                  subtitle: Text('Free up device storage'),
                  trailing: Icon(Icons.delete_outline),
                  onTap: () {
                    // Clear app cache
                    _showClearCacheDialog();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Terms of Service'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Show terms of service
                  },
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Privacy Policy'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Contact Support'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // Contact support
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {
                // Log out
                _showLogoutDialog();
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Blue'),
                value: 'Blue',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    Navigator.of(context).pop();
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Green'),
                value: 'Green',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    Navigator.of(context).pop();
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Purple'),
                value: 'Purple',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    Navigator.of(context).pop();
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('Dark'),
                value: 'Dark',
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                    _darkModeEnabled = true;
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear Cache'),
          content: Text('Are you sure you want to clear the app cache? This will remove all downloaded videos and resources.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Clear cache logic
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cache cleared successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logout logic
                Navigator.of(context).pop();
                // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}