import 'package:flutter/material.dart';
import 'package:mobile_project/models/product.dart'; // Import Product model

class CartController extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners(); // Notify listeners when the cart changes
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners(); // Notify listeners when the cart changes
  }

  void decreaseQuantity(String productId) {
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      removeItem(productId);
    }
    notifyListeners(); // Notify listeners when the cart changes
  }

  void clearCart() {
    _items.clear();
    notifyListeners(); // Notify listeners when the cart changes
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.discountedPrice * quantity;
}