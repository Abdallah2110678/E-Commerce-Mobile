class OrderItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final String thumbnailUrl;

  OrderItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.quantity,
    required this.price,
    required this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'quantity': quantity,
      'price': price,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      productId: map['productId'],
      title: map['title'],
      quantity: map['quantity'],
      price: map['price'],
      thumbnailUrl: map['thumbnailUrl'],
    );
  }
}
