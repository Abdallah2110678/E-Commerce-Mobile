import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/models/cart.dart';
import 'package:mobile_project/models/product.dart';

class CartController extends StateNotifier<Map<String, CartItem>> {
  CartController() : super({});

  // Add a product to the cart
  void addItem(Product product) {
    if (state.containsKey(product.id)) {
      state = {
        ...state,
        product.id: CartItem(
          product: product,
          quantity: state[product.id]!.quantity + 1,
        ),
      };
    } else {
      state = {
        ...state,
        product.id: CartItem(product: product),
      };
    }
  }

  // Remove a product from the cart
  void removeItem(String productId) {
    state = {...state};
    state.remove(productId);
  }

  // Decrease the quantity of a product in the cart
  void decreaseQuantity(String productId) {
    if (state[productId]!.quantity > 1) {
      state = {
        ...state,
        productId: CartItem(
          product: state[productId]!.product,
          quantity: state[productId]!.quantity - 1,
        ),
      };
    } else {
      removeItem(productId);
    }
  }

  // Clear the cart
  void clearCart() {
    state = {};
  }

  // Get the total amount of the cart
  double get totalAmount {
    return state.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

// Create a StateNotifierProvider for the CartController
final cartControllerProvider = StateNotifierProvider<CartController, Map<String, CartItem>>((ref) {
  return CartController();
});