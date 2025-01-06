// lib/views/product_table_view.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/controllers/product_controller.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/screens/dashboard/products/updateProduct.dart';

class ProductTableView extends StatefulWidget {
  const ProductTableView({super.key});

  @override
  _ProductTableViewState createState() => _ProductTableViewState();
}

class _ProductTableViewState extends State<ProductTableView> {
  final ProductController _controller = ProductController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await _controller.fetchProducts();
    setState(() => _isLoading = false);
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      await _controller.deleteProduct(product);
      _controller.products.remove(product);
      setState(() => _isLoading = false);
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     // Add product logic here
                //   },
                //   child: const Text('Add Product'),
                // ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: _searchProducts,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey[200],
                        ),
                        columns: const [
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Thumbnail', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _controller.products
                            .where((product) => product.title.toLowerCase().contains(_searchQuery))
                            .map((product) {
                          return DataRow(cells: [
                            DataCell(Text(product.title)),
                            DataCell(Text(product.stock.toString())),
                            DataCell(Center(child: Image.network(product.thumbnailUrl,width: 70,))),
                            DataCell(Center(child: Image.network(product.brand.logoUrl,width: 70,))),
                            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteProduct(product),
                                    
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue,),
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProductView(product: product))),
                                    
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
            if (_controller.hasMore)
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Load More'),
              ),
          ],
        ),
      ),
    );
  }
}
