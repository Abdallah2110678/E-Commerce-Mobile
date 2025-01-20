import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/widgets/products/product_cards/product_card_vertical.dart';
import 'package:mobile_project/controllers/all_products_controller.dart';

class AllProductsScreen extends StatelessWidget {
  final List<Product> products;

  const AllProductsScreen({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return ChangeNotifierProvider(
      create: (_) {
        final controller = AllProductsController();
        controller.initialize(products);
        return controller;
      },
      child: Scaffold(
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
            Consumer<AllProductsController>(
              builder: (context, controller, child) {
                return DropdownButton<String>(
                  value: controller.sortBy,
                  onChanged: (String? newValue) {
                    controller.updateSortBy(newValue!);
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
                );
              },
            ),
            // Ascending/Descending toggle
            Consumer<AllProductsController>(
              builder: (context, controller, child) {
                return IconButton(
                  icon: Icon(
                    controller.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: dark ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    controller.toggleSortOrder();
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Consumer<AllProductsController>(
                builder: (context, controller, child) {
                  return TextField(
                    controller: controller.searchController,
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
                        borderRadius:
                            BorderRadius.circular(TSizes.borderRadiusLg),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                    ),
                    onChanged: controller.filterProducts,
                  );
                },
              ),
            ),
            // Product grid
            Expanded(
              child: Consumer<AllProductsController>(
                builder: (context, controller, child) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: TSizes.defaultSpace,
                      mainAxisSpacing: TSizes.defaultSpace,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      return TProductCardVertical(
                        product: controller.filteredProducts[index],
                        isHomeScreen: false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: dark ? Colors.grey[900] : Colors.white,
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}