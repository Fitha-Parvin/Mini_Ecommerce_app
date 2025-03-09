import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Save user data in Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? "New User",
          "email": user.email ?? "",
          "profileImageUrl": user.photoURL ?? "",
        });
        print("✅ User saved to Firestore: ${user.uid}");
      }
    } catch (e) {
      print("🔥 Error saving user to Firestore: $e");
    }
  }

  // ✅ Sign Up with Email & Password
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data in Firestore
      await _saveUserToFirestore(userCredential.user!);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save user data in Firestore
      await _saveUserToFirestore(userCredential.user!);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ Sign In with Email & Password
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    notifyListeners();
  }
}
