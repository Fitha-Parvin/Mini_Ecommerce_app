import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/provider/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData();

      // ✅ Initialize user details
      if (userProvider.user != null) {
        _nameController.text = userProvider.user!['name'] ?? '';
      }
    });
  }

  // ✅ Show bottom sheet for image selection
  Future<void> _showImagePicker() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // ✅ Pick image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
    }
  }

  // ✅ Upload Image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return '';

      final storageRef =
      FirebaseStorage.instance.ref().child("profile_images/$uid.jpg");
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Error uploading image: $e");
      return '';
    }
  }

  // ✅ Update Profile Data
  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isUpdating = true;
    });

    String imageUrl = userProvider.user?['profileImageUrl'] ?? '';
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    await userProvider.updateUserProfile(_nameController.text, imageUrl);

    setState(() {
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImagePicker, // ✅ Open image picker on tap
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user?['profileImageUrl'] != null &&
                        user?['profileImageUrl'].isNotEmpty
                        ? CachedNetworkImageProvider(user?['profileImageUrl'])
                        : const AssetImage("assets/default_avatar.png"))
                    as ImageProvider,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt, size: 25, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: _isUpdating
                  ? const CircularProgressIndicator()
                  : const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
