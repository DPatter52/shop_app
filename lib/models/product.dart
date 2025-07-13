class Product {
  final String id;
  final String title;
  final String description;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}
