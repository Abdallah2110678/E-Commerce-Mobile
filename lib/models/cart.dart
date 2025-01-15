import 'package:mobile_project/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.discountedPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toFirestore(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {required Product product}) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
    );
  }
}