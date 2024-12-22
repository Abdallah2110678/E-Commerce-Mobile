import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_project/controllers/category_controller.dart';
import 'package:mobile_project/controllers/product_controller.dart';
import 'package:mobile_project/models/brand.dart';
import 'package:mobile_project/models/category.dart';
import 'package:mobile_project/utils/constants/colors.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  _AddProductViewState createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {

String selectedThumbnail="";
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

  // Check if thumbnail is selected
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
      brand: Brand(id: "vOnJPUIs2JTC2cUTGgBj", name: "name", logoUrl: "logoUrl") // Safely use _selectedCategory
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
              
              
              _buildGalleryImagesCard(),
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
            _buildSectionTitle("Product Thumbnail"),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showImagePicker(true),
              child: selectedThumbnail == ""
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _buildGalleryImagesCard() {
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
            _buildSectionTitle("Product Images"),
            const SizedBox(height: 16),
            selectedImages.isEmpty
                ? GestureDetector(
                    onTap: () => _showImagePicker(false),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == selectedImages.length) {
                        return GestureDetector(
                          onTap: () => _showImagePicker(false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
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
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
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



class ProductImagePicker extends StatefulWidget {
  final Function(String) onThumbnailSelected;
  final Function(List<String>) onImagesSelected;
  final bool isThumbnailPicker;
  final List<String> selectedImages;

  const ProductImagePicker({
    Key? key,
    required this.onThumbnailSelected,
    required this.onImagesSelected,
    required this.isThumbnailPicker,
    required this.selectedImages,
  }) : super(key: key);

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  List<String> tempSelectedImages = [];

  @override
  void initState() {
    super.initState();
    tempSelectedImages = List.from(widget.selectedImages);
  }

  final List<String> availableImages = [
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
    'https://static.vecteezy.com/ti/photos-gratuite/t2/48021360-colore-lezard-dans-neon-couleurs-fonce-contexte-avec-une-fermer-photo.jpg',
    'https://img.freepik.com/photos-gratuite/gros-plan-iguane-dans-nature_23-2151718784.jpg',
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
    'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
  ];

  void _toggleImageSelection(String imagePath) {
    setState(() {
      if (widget.isThumbnailPicker) {
        tempSelectedImages = [imagePath];
      } else {
        if (tempSelectedImages.contains(imagePath)) {
          tempSelectedImages.remove(imagePath);
        } else {
          tempSelectedImages.add(imagePath);
        }
      }
    });
  }

  void _confirmSelection() {
    if (widget.isThumbnailPicker && tempSelectedImages.isNotEmpty) {
      widget.onThumbnailSelected(tempSelectedImages.first);
    } else {
      widget.onImagesSelected(tempSelectedImages);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isThumbnailPicker ? 'Select Thumbnail' : 'Select Images',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: _confirmSelection,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableImages.length,
                itemBuilder: (context, index) {
                  final imagePath = availableImages[index];
                  final isSelected = tempSelectedImages.contains(imagePath);

                  return GestureDetector(
                    onTap: () => _toggleImageSelection(imagePath),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _toggleImageSelection(imagePath),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}