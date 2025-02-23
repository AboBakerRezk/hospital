import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    userName = user?.displayName ?? "User";
    userPhotoUrl = user?.photoURL;
  }

  /// Greeting section that shows the user's photo, name, and a welcome message.
  Widget _buildGreetingSection() {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
        child: userPhotoUrl == null
            ? Icon(Icons.person, size: 30, color: Colors.white)
            : null,
        backgroundColor: Colors.teal[700],
      ),
      title: Text(
        'Hello, $userName',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Wishing you a day full of health and success!'),
    );
  }

  /// Recommendations carousel using data from Firestore collection "recommendations".
  Widget _buildRecommendationsCarousel() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            height: 150,
            child: Center(child: Text('No recommendations at the moment.')),
          );
        }
        return Container(
          height: 180,
          child: PageView.builder(
            itemCount: docs.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Recommendation';
              final description = data['description'] ?? '';
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.teal[100],
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Upcoming appointments section with sample data.
  Widget _buildUpcomingAppointments() {
    final appointments = [
      {'time': '10:00 AM', 'doctor': 'Dr. Ahmed', 'department': 'Cardiology'},
      {'time': '2:00 PM', 'doctor': 'Dr. Sara', 'department': 'Endocrinology'},
    ];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...appointments.map((appt) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                Icon(Icons.calendar_today, color: Colors.teal[700]),
                title:
                Text('${appt['time']} with ${appt['doctor']}'),
                subtitle: Text('${appt['department']}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Shortcuts grid for quick access to different app sections.
  Widget _buildShortcutsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildShortcutCard(Icons.chat, 'Chat', () {
          Navigator.pushNamed(context, '/chat');
        }),
        _buildShortcutCard(Icons.people, 'Patients', () {
          Navigator.pushNamed(context, '/patients');
        }),
        _buildShortcutCard(Icons.settings, 'Settings', () {
          Navigator.pushNamed(context, '/settings');
        }),
        _buildShortcutCard(Icons.history, 'Recommendation Log', () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Feature under development')));
        }),
      ],
    );
  }

  Widget _buildShortcutCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        color: Colors.teal[50],
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.teal[700]),
              SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  /// Notifications section using Firestore collection "notifications".
  Widget _buildNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
              height: 80,
              child: Center(child: CircularProgressIndicator()));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
              height: 80,
              child: Center(child: Text('No new notifications')));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final content = data['content'] ?? '';
              return ListTile(
                leading: Icon(Icons.notification_important,
                    color: Colors.teal[700]),
                title: Text(content, style: TextStyle(fontSize: 14)),
                dense: true,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reload Page',
            onPressed: () {
              setState(() {}); // Reload page
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName ?? "User"),
              accountEmail: Text(_auth.currentUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName != null && userName!.isNotEmpty
                      ? userName![0]
                      : "U",
                  style: TextStyle(fontSize: 40.0, color: Colors.teal[700]),
                ),
              ),
              decoration: BoxDecoration(color: Colors.teal[700]),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Patients'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/patients');
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/chat');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // Reload data on pull
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildGreetingSection(),
            SizedBox(height: 16),
            _buildRecommendationsCarousel(),
            SizedBox(height: 16),
            _buildUpcomingAppointments(),
            SizedBox(height: 16),
            _buildShortcutsGrid(),
            SizedBox(height: 16),
            _buildNotifications(),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.teal[700],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
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
