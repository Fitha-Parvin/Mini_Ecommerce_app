import 'package:ecommerce_app/provider/cart.dart';
import 'package:ecommerce_app/provider/notification.dart';
import 'package:ecommerce_app/provider/product.dart';
import 'package:ecommerce_app/provider/user.dart';
import 'package:ecommerce_app/screens/Login.dart';
import 'package:ecommerce_app/screens/root.dart';
import 'package:ecommerce_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAH8ntCkTDJFF9tX-ivcfrQPvBa_6XeYiw",
      appId: "1:591767754673:android:b22863304bb5e887560f90",
      storageBucket: "ecommerce-19361.firebasestorage.app",
      projectId: "ecommerce-19361",
      messagingSenderId: "591767754673", // Ensure this is correct
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..fetchProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          return StreamBuilder<User?>(
            stream: authService.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                return const RootScreen();
              }

              return const LoginScreen();
            },
          );
        },
      ),
    );
  }
}
