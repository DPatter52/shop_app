class Order {
  final String id;
  final double amount;
  final List<Map<String, dynamic>> products;
  final DateTime dateTime;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'amount': amount,
      'products': products,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Order.fromMap(String id, Map<String, dynamic> data) {
    return Order(
      id: id,
      amount: data['amount'],
      products: List<Map<String, dynamic>>.from(data['products']),
      dateTime: DateTime.parse(data['dateTime']),
    );
  }
}
