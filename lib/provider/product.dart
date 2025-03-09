import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/material.dart';


class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Product').get();
      _products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
