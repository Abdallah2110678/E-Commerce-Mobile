import 'package:flutter/material.dart';
import 'package:mobile_project/models/product.dart';

class AllProductsController extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Default ascending order

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  TextEditingController get searchController => _searchController;
  String get sortBy => _sortBy;
  bool get ascending => _ascending;

  // Initialize the controller with products
  void initialize(List<Product> products) {
    _products = products;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  // Filter products based on search query
  void filterProducts(String query) {
    _filteredProducts = _products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  // Sort products based on the selected criteria
  void sortProducts() {
    if (_sortBy == 'name') {
      _filteredProducts.sort((a, b) => _ascending
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title));
    } else if (_sortBy == 'price') {
      _filteredProducts.sort((a, b) => _ascending
          ? a.discountedPrice.compareTo(b.discountedPrice)
          : b.discountedPrice.compareTo(a.discountedPrice));
    }
    notifyListeners();
  }

  // Update sorting criteria
  void updateSortBy(String newValue) {
    _sortBy = newValue;
    sortProducts();
  }

  // Toggle ascending/descending order
  void toggleSortOrder() {
    _ascending = !_ascending;
    sortProducts();
  }
}