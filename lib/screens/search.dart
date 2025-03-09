import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/provider/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String _selectedCategory = "All";


  final List<String> _categories = ["All", "Electronics", "Clothing", "Shoes", "Accessories"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  void _filterProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    String query = _searchController.text.toLowerCase();

    final filtered = productProvider.products.where((product) {
      bool matchesQuery = product.name.toLowerCase().contains(query);
      bool matchesCategory = _selectedCategory == "All" || product.Category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    // Only update if the filtered list changes
    if (_filteredProducts.length != filtered.length || !_filteredProducts.every(filtered.contains)) {
      setState(() {
        _filteredProducts = filtered;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final allProducts = productProvider.products;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          _buildCategoryFilter(),
          Expanded(
            child: _filteredProducts.isEmpty && _searchController.text.isEmpty && _selectedCategory == "All"
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                const Text(
                  "Browse products or use search.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildProductGrid(allProducts)) // Show all products initially
              ],
            )
                : _filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : _buildProductGrid(_filteredProducts),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: _selectedCategory == category ? Colors.white : Colors.black,
                ),
                onSelected: (selected) => _filterByCategory(category),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "\$${product.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
