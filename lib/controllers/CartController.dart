import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_project/controllers/authProvider.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/cart.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';

class CartController extends StateNotifier<Map<String, CartItem>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  CartController(this.userId) : super({}) {
    _loadCart();
  }

  // Load the cart from Firestore
  Future<void> _loadCart() async {
    final cartDoc = await _firestore.collection('carts').doc(userId).get();
    if (cartDoc.exists) {
      final cartData = cartDoc.data() as Map<String, dynamic>;
      final cartItems = <String, CartItem>{};
      for (var entry in cartData.entries) {
        final product = Product.fromFirestore(
          await _firestore.collection('products').doc(entry.key).get(),
          category: Category.empty(), // Replace with actual category
          brand: Brand.empty(), // Replace with actual brand
        );
        cartItems[entry.key] = CartItem.fromMap(entry.value, product: product);
      }
      state = cartItems;
    }
  }

  // Save the cart to Firestore
  Future<void> _saveCart() async {
    final cartMap = state.map((key, value) => MapEntry(key, value.toMap()));
    await _firestore.collection('carts').doc(userId).set(cartMap);
  }

  // Add a product to the cart
  void addItem(Product product) async {
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
    await _saveCart();
  }

  // Remove a product from the cart
  void removeItem(String productId) async {
    state = {...state};
    state.remove(productId);
    await _saveCart();
  }

  // Decrease the quantity of a product in the cart
  void decreaseQuantity(String productId) async {
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
    await _saveCart();
  }

  // Clear the cart
  void clearCart() async {
    state = {};
    await _saveCart();
  }

  // Get the total amount of the cart
  double get totalAmount {
    return state.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

// Create a StateNotifierProvider for the CartController
final cartControllerProvider =
    StateNotifierProvider<CartController, Map<String, CartItem>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    throw Exception('User is not authenticated');
  }
  return CartController(userId);
});
