import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_project/controllers/category_controller.dart';
import 'package:mobile_project/controllers/product_controller.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/validators/validation.dart';
import 'package:mobile_project/widgets/custom_shapes/rounded_container.dart';
import 'package:mobile_project/widgets/products/product_image_picker.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  String selectedThumbnail = "";
  List<String> selectedImages = [];

  final _formKey = GlobalKey<FormState>();
  final _productController = ProductController();
  final _categoryController = CategoryController();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();

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

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedThumbnail == "" || selectedThumbnail.isEmpty) {
      _showErrorSnackBar('Please select a thumbnail image');
      return;
    }

    // Check if at least one image is selected
    if (selectedImages.isEmpty) {
      _showErrorSnackBar('Please add at least one gallery image');
      return;
    }

    // Check if category is selected
    if (_selectedCategory == null) {
      _showErrorSnackBar('Please select a category');
      return;
    }

    try {
      await _productController.createProduct(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          thumbnailUrl: selectedThumbnail,
          imageUrls: selectedImages,
          price: double.parse(_priceController.text),
          discount: double.parse(_discountController.text),
          stock: int.parse(_stockController.text),
          category: _selectedCategory!,
          brand: Brand(
              id: "vOnJPUIs2JTC2cUTGgBj",
              name: "name",
              logoUrl: "logoUrl") // Safely use _selectedCategory
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
      selectedThumbnail = "";
      selectedImages.clear();
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

  void _showImagePicker(bool isThumbnail) {
    showDialog(
      context: context,
      builder: (context) => ProductImagePicker(
        isThumbnailPicker: isThumbnail,
        selectedImages: isThumbnail
            ? (selectedThumbnail != "" ? [selectedThumbnail] : [])
            : selectedImages,
        onThumbnailSelected: (imagePath) {
          setState(() {
            selectedThumbnail = imagePath;
          });
        },
        onImagesSelected: (images) {
          setState(() {
            selectedImages = images;
          });
        },
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
            child: TRoundedContainer(
              showBorder: true,
              backgroundColor: THelperFunctions.isDarkMode(context)
                  ? TColors.dark
                  : TColors.light,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Product Information",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: _buildInputDecoration("Product Title"),
                        validator: TValidator.validateNonEmptyField,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration:
                            _buildInputDecoration("Product Description"),
                        validator: TValidator.validateNonEmptyField,
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
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration("Price"),
                        validator: (value) =>
                            TValidator.validatePositiveNumber(value),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Discount'),
                        validator: TValidator.validatePercentage,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Stock'),
                        validator: TValidator.validateNonNegativeInteger,
                      ),

                      // thumbnail image
                      const SizedBox(height: 15),
                      TRoundedContainer(
                        showBorder: true,
                        backgroundColor: THelperFunctions.isDarkMode(context)
                            ? TColors.dark
                            : TColors.light,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  ("Product Thumbnail"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _showImagePicker(true),
                                child: selectedThumbnail == ""
                                    ? Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text('Select Thumbnail'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        selectedThumbnail,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // select images

                      TRoundedContainer(
                        showBorder: true,
                        backgroundColor: THelperFunctions.isDarkMode(context)
                            ? TColors.dark
                            : TColors.light,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "Product Images",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              selectedImages.isEmpty
                                  ? GestureDetector(
                                      onTap: () => _showImagePicker(false),
                                      child: Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text('Add Product Images'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: selectedImages.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == selectedImages.length) {
                                          return GestureDetector(
                                            onTap: () =>
                                                _showImagePicker(false),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return Stack(
                                          children: [
                                            Image.network(
                                              selectedImages[index],
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedImages
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // submit button
                      SizedBox(
                        // or Container
                        width: double.infinity,
                        child: ElevatedButton(
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
                        ),
                      )
                    ]),
              ),
            )),
      ),
    );
  }
}
