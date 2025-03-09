import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  // 🔹 Fetch User Data from Firestore
  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        _user = doc.data();
      } else {
        _user = null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Update User Profile
  Future<void> updateUserProfile(String name, String imageUrl) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'profileImageUrl': imageUrl,
      });

      // ✅ Update local state
      _user?['name'] = name;
      _user?['profileImageUrl'] = imageUrl;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
    }
  }
}
