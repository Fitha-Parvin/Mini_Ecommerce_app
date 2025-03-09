import 'package:ecommerce_app/provider/notification.dart';
import 'package:ecommerce_app/screens/product_card.dart';
import 'package:ecommerce_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart.dart';
import '../provider/product.dart';
import 'cart.dart'; // Ensure this file exists

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple to Blue Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      user != null
                          ? "Hi, ${user.displayName ?? user.email!.split('@')[0]}" // Show name if available, otherwise email
                          : "Welcome", // If no user is logged in
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, size: 28, color: Colors.white),
                          onPressed: () {
                            notificationProvider.clearNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("No new notifications")),
                            );
                          },
                        ),
                        if (notificationProvider.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                notificationProvider.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Product Grid
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return productProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : productProvider.products.isEmpty
                        ? const Center(
                      child: Text(
                        "No products available",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Two products per row
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: productProvider.products[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
