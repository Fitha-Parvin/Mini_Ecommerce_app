class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String Category;
  final bool isAvailable; //

  Product({
    required this.Category,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.isAvailable, //
  });

  factory Product.fromMap(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? 'No Name',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No Description',
      isAvailable: data['isAvailable'] ?? false, Category: '', //
    );
  }


}
