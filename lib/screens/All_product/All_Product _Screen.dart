import 'package:flutter/material.dart';
import 'package:mobile_project/models/product.dart'; // Import Product model
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart'; // Import THelperFunctions
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart'; // Import TProductCardVertical

class AllProductsScreen extends StatefulWidget {
  final List<Product> products;

  const AllProductsScreen({Key? key, required this.products}) : super(key: key);

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late List<Product> _filteredProducts;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'name'; // Default sorting by name
  bool _ascending = true; // Default ascending order

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(widget.products);
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = widget.products
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _sortProducts() {
    setState(() {
      if (_sortBy == 'name') {
        _filteredProducts.sort((a, b) => _ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
      } else if (_sortBy == 'price') {
        _filteredProducts.sort((a, b) => _ascending
            ? a.discountedPrice.compareTo(b.discountedPrice)
            : b.discountedPrice.compareTo(a.discountedPrice));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Products',
          style: TextStyle(color: dark ? Colors.white : Colors.black),
        ),
        backgroundColor: dark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(
          color: dark ? Colors.white : Colors.black, // Back button color
        ),
        actions: [
          // Sorting dropdown
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
                _sortProducts();
              });
            },
            items: <String>['name', 'price']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  'Sort by ${value.capitalize()}',
                  style: TextStyle(
                    color: dark ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
            dropdownColor: dark ? Colors.grey[800] : Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          // Ascending/Descending toggle
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: dark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
                _sortProducts();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: TextStyle(
                  color: dark ? Colors.white54 : Colors.black54,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: dark ? Colors.white54 : Colors.black54,
                ),
                filled: true,
                fillColor: dark ? Colors.grey[800] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: dark ? Colors.white : Colors.black,
              ),
              onChanged: _filterProducts,
            ),
          ),
          // Product grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: TSizes.defaultSpace,
                mainAxisSpacing: TSizes.defaultSpace,
                childAspectRatio: 0.6,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return TProductCardVertical(
                  product: _filteredProducts[index],
                  isHomeScreen: false,
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: dark ? Colors.grey[900] : Colors.white,
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}