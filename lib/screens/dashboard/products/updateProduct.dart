import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/models/product.dart';
import 'package:mobile_project/widgets/products/product_image_picker.dart';

class UpdateProductView extends StatefulWidget {
  final Product product;

  const UpdateProductView({Key? key, required this.product}) : super(key: key);

  @override
  _UpdateProductViewState createState() => _UpdateProductViewState();
}

class _UpdateProductViewState extends State<UpdateProductView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  
  String _selectedThumbnail = "";
  List<String> _selectedImages = [];
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController.text = widget.product.title;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _discountController.text = widget.product.discount.toString();
    _stockController.text = widget.product.stock.toString();
    _selectedThumbnail = widget.product.thumbnailUrl;
    _selectedImages = List.from(widget.product.imageUrls);
    _selectedCategory = widget.product.category;
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedThumbnail.isEmpty) {
      _showError('Please select a thumbnail image');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showError('Please add at least one product image');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedProduct = Product(
        id: widget.product.id,
        title: _titleController.text,
        description: _descriptionController.text,
        thumbnailUrl: _selectedThumbnail,
        imageUrls: _selectedImages,
        price: double.parse(_priceController.text),
        discount: double.parse(_discountController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory!,
        brand: widget.product.brand,
      );

      await FirebaseFirestore.instance
          .collection('products')
          .doc(updatedProduct.id)
          .update(updatedProduct.toFirestore());

      Navigator.pop(context, updatedProduct);
      _showSuccess('Product updated successfully');
    } catch (e) {
      _showError('Failed to update product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImagePicker(bool isThumbnail) {
    showDialog(
      context: context,
      builder: (context) => ProductImagePicker(
        isThumbnailPicker: isThumbnail,
        selectedImages: isThumbnail 
            ? [_selectedThumbnail]
            : _selectedImages,
        onThumbnailSelected: (path) {
          setState(() => _selectedThumbnail = path);
        },
        onImagesSelected: (images) {
          setState(() => _selectedImages = images);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
        actions: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoSection(),
              const SizedBox(height: 20),
              _buildPricingSection(),
              const SizedBox(height: 20),
              _buildImagesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter description' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              items: _buildCategoryItems(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Discount %'),
              validator: _validateDiscount,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
              validator: _validateStock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thumbnail'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImagePicker(true),
              child: _selectedThumbnail.isEmpty
                  ? _buildImagePlaceholder('Select Thumbnail')
                  : Image.network(_selectedThumbnail, height: 200),
            ),
            const SizedBox(height: 16),
            const Text('Gallery Images'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: () => _showImagePicker(false),
                    child: _buildImagePlaceholder('Add Image'),
                  );
                }
                return Stack(
                  children: [
                    Image.network(_selectedImages[index], fit: BoxFit.cover),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String text) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate),
            Text(text),
          ],
        ),
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Please enter price';
    if (double.tryParse(value) == null) return 'Invalid price';
    if (double.parse(value) <= 0) return 'Price must be greater than 0';
    return null;
  }

  String? _validateDiscount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter discount';
    if (double.tryParse(value) == null) return 'Invalid discount';
    if (double.parse(value) < 0 || double.parse(value) > 100) {
      return 'Discount must be between 0 and 100';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.isEmpty) return 'Please enter stock';
    if (int.tryParse(value) == null) return 'Invalid stock quantity';
    if (int.parse(value) < 0) return 'Stock cannot be negative';
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  List<DropdownMenuItem<Category>> _buildCategoryItems() {
    // Replace this with your actual categories
    return [
      DropdownMenuItem(
        value: _selectedCategory,
        child: Text(_selectedCategory?.name ?? ''),
      ),
    ];
  }
}