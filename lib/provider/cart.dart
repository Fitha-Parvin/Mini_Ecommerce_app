import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _cartItems = {}; // Stores product ID and quantity
  final Map<String, Product> _productDetails = {}; // Stores product details

  Map<String, int> get cartItems => _cartItems;

  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id] = _cartItems[product.id]! + 1;
    } else {
      _cartItems[product.id] = 1;
      _productDetails[product.id] = product;
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (_cartItems.containsKey(productId)) {
      if (_cartItems[productId]! > 1) {
        _cartItems[productId] = _cartItems[productId]! - 1;
      } else {
        removeFromCart(productId);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    _productDetails.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _productDetails.clear();
    notifyListeners();
  }

  Product getProductDetails(String productId) {
    return _productDetails[productId] ?? Product(
      id: productId,
      name: "Unknown Product",
      price: 0.0,
      imageUrl: "",
      description: "No description available.",
      isAvailable: true, Category: '', // ✅ Default to true if missing
    );
  }

  int get cartCount => _cartItems.length;

  double get totalPrice => _cartItems.entries.fold(
    0,
        (sum, item) =>
    sum + (_productDetails[item.key]?.price ?? 0) * item.value,
  );
}
