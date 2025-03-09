import 'package:ecommerce_app/screens/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String firstName = "";
  String lastName = "";
  String phone = "";
  String email = "";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (user != null) {
      email = user!.email ?? "";
      setState(() {}); // Update UI with email

      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          firstName = snapshot['firstName'] ?? "";
          lastName = snapshot['lastName'] ?? "";
          phone = snapshot['phone'] ?? "";
          profileImageUrl = snapshot['profileImageUrl'] ?? "";
        });
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((_) => _fetchUserProfile()); // Refresh profile after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profileImageUrl.isNotEmpty
                  ? NetworkImage(profileImageUrl)
                  : AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              "$firstName $lastName",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(email, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Edit Profile"),
            ),
            SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(Icons.favorite, "Favourites"),
                  _buildProfileOption(Icons.download, "Downloads"),
                  _buildProfileOption(Icons.language, "Language"),
                  _buildProfileOption(Icons.location_on, "Location"),
                  _buildProfileOption(Icons.display_settings, "Display"),
                  _buildProfileOption(Icons.subscriptions, "Subscription"),
                  Divider(),
                  _buildProfileOption(Icons.delete, "Clear Cache"),
                  _buildProfileOption(Icons.history, "Clear History"),
                  _buildProfileOption(Icons.logout, "Log Out", logout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool logout = false}) {
    return ListTile(
      leading: Icon(icon, color: logout ? Colors.red : Colors.black),
      title: Text(title),
      onTap: () {
        if (logout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
        }
      },
    );
  }
}
