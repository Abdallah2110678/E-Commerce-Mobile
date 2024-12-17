import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/controllers/category_controller.dart';
import 'package:mobile_project/controllers/product/product_controller.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/utils/constants/colors.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({Key? key}) : super(key: key);

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _productController = ProductController();
  final _categoryController = CategoryController();
  final _imagePicker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();

  // Image states
  File? _thumbnailImage;
  List<File> _galleryImages = [];

  // Category state
  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _categoryController.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to fetch categories: $e');
    }
  }

  Future<void> _pickImage({required bool isThumbnail}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          if (isThumbnail) {
            _thumbnailImage = File(pickedFile.path);
          } else {
            _galleryImages.add(File(pickedFile.path));
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailImage == null) {
      _showErrorSnackBar('Please select a thumbnail image');
      return;
    }

    if (_galleryImages.isEmpty) {
      _showErrorSnackBar('Please add at least one gallery image');
      return;
    }

    try {
      await _productController.createProduct(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        thumbnail: _thumbnailImage!,
        images: _galleryImages,
        price: double.parse(_priceController.text),
        discount: double.parse(_discountController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory!,
      );

      _showSuccessSnackBar('Product created successfully');
      _resetForm();
    } catch (e) {
      _showErrorSnackBar('Failed to create product: $e');
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _discountController.clear();
      _stockController.clear();
      _thumbnailImage = null;
      _galleryImages.clear();
      _selectedCategory = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoCard(),
              const SizedBox(height: 25),
              _buildStockAndPricingCard(),
              const SizedBox(height: 25),
              _buildThumbnailPickerCard(),
              const SizedBox(height: 25),
              _buildImageSelectionSection(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Basic Information"),
            TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration("Product Title"),
              validator: InputValidators.validateNonEmptyField,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: _buildInputDecoration("Product Description"),
              validator: InputValidators.validateNonEmptyField,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAndPricingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Stock and Pricing"),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration("Price"),
              validator: InputValidators.validatePositiveNumber,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Discount'),
              validator: InputValidators.validatePercentage,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Stock'),
              validator: InputValidators.validateNonNegativeInteger,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailPickerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Pick Thumbnail"),
            GestureDetector(
              onTap: () => _pickImage(isThumbnail: true),
              child: _thumbnailImage == null
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Image.file(
                      _thumbnailImage!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(isThumbnail: false),
          child: const Text('Pick Gallery Images'),
        ),
        Text('${_galleryImages.length} images selected'),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitProduct,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Submit Product',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TColors.primary,
        ),
      ),
    );
  }
}

class InputValidators {
  static String? validateNonEmptyField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a valid positive number';
    }
    return null;
  }

  static String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Discount is required';
    }
    final number = double.tryParse(value);
    if (number == null || number < 0 || number > 100) {
      return 'Please enter a valid percentage (0-100)';
    }
    return null;
  }

  static String? validateNonNegativeInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock is required';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Please enter a valid non-negative number';
    }
    return null;
  }
}