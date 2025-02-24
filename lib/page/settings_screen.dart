import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Change password dialog
  void _changePassword() {
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Password'),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'New Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await currentUser!.updatePassword(newPasswordController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password changed successfully')),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  // Update email dialog
  void _updateEmail() {
    final newEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Email'),
        content: TextField(
          controller: newEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'New Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await currentUser!.updateEmail(newEmailController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Email updated successfully')),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  // Clear cache (example)
  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache cleared')),
    );
  }

  // Send feedback
  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback feature under development')),
    );
  }

  // Contact Us
  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact Us feature under development')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          // User Header
          Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: currentUser?.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
                child: currentUser?.photoURL == null
                    ? Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
                backgroundColor: Colors.teal,
              ),
              title: Text(
                currentUser?.displayName ?? 'User',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(currentUser?.email ?? ''),
            ),
          ),
          // Account Settings
          ExpansionTile(
            leading: Icon(Icons.person, color: Colors.teal),
            title: Text('Account Settings'),
            children: [
              ListTile(
                leading: Icon(Icons.lock_outline, color: Colors.teal),
                title: Text('Change Password'),
                onTap: _changePassword,
              ),
              ListTile(
                leading: Icon(Icons.email_outlined, color: Colors.teal),
                title: Text('Update Email'),
                onTap: _updateEmail,
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: Colors.teal),
                title: Text('Update Profile Picture'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile picture update under development')),
                  );
                },
              ),
            ],
          ),
          // Notification Settings
          ExpansionTile(
            leading: Icon(Icons.notifications, color: Colors.teal),
            title: Text('Notification Settings'),
            children: [
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: true,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification settings updated')),
                  );
                },
                secondary: Icon(Icons.notifications_active, color: Colors.teal),
              ),
              ListTile(
                leading: Icon(Icons.volume_up, color: Colors.teal),
                title: Text('Notification Sound'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification sound feature under development')),
                  );
                },
              ),
            ],
          ),
          // App Preferences
          ExpansionTile(
            leading: Icon(Icons.settings, color: Colors.teal),
            title: Text('App Preferences'),
            children: [
              SwitchListTile(
                title: Text('Dark Theme'),
                value: isDarkTheme,
                onChanged: (val) {
                  setState(() {
                    isDarkTheme = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Theme updated')),
                  );
                },
                secondary: Icon(Icons.dark_mode, color: Colors.teal),
              ),
              ListTile(
                leading: Icon(Icons.cleaning_services, color: Colors.teal),
                title: Text('Clear Cache'),
                onTap: _clearCache,
              ),
            ],
          ),
          // Support & Help
          ExpansionTile(
            leading: Icon(Icons.support, color: Colors.teal),
            title: Text('Support & Help'),
            children: [
              ListTile(
                leading: Icon(Icons.feedback, color: Colors.teal),
                title: Text('Send Feedback'),
                onTap: _sendFeedback,
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.teal),
                title: Text('About the App'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Health Assistant',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(Icons.local_hospital, size: 40, color: Colors.teal),
                    children: [
                      Text('This app helps manage medical information and notifications.'),
                    ],
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail, color: Colors.teal),
                title: Text('Contact Us'),
                onTap: _contactUs,
              ),
            ],
          ),
          SizedBox(height: 20),
          // Logout Button
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _logout,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.teal,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/patients');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }
}
