// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:money_tracking/Model/hive.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  ProfileScreen({required this.onLogout});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final settingsBox = Hive.box('settings');
    final userBox = Hive.box<User>('users');
    final currentUserId = settingsBox.get('currentUserId');

    if (currentUserId != null) {
      for (var user in userBox.values) {
        if (user.id == currentUserId) {
          setState(() {
            currentUser = user;
          });
          break;
        }
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onLogout();
                },
                child: Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body:
          currentUser == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.teal,
                            child: Text(
                              currentUser!.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            currentUser!.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            currentUser!.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Member since ${currentUser!.createdAt.day}/${currentUser!.createdAt.month}/${currentUser!.createdAt.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Settings Options
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(Icons.person, 'Edit Profile', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Feature coming soon!')),
                            );
                          }),
                          Divider(height: 1),
                          _buildSettingItem(
                            Icons.notifications,
                            'Notifications',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Feature coming soon!')),
                              );
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingItem(
                            Icons.security,
                            'Privacy & Security',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Feature coming soon!')),
                              );
                            },
                          ),
                          Divider(height: 1),
                          _buildSettingItem(Icons.help, 'Help & Support', () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Feature coming soon!')),
                            );
                          }),
                          Divider(height: 1),
                          _buildSettingItem(Icons.info, 'About', () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: Text('About'),
                                    content: Text(
                                      'Expense Tracker v1.0\n\nA simple and efficient way to track your income and expenses.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(ctx).pop(),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
