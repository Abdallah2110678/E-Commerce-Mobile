// import 'package:flutter/material.dart';
// import '../controllers/category_controller.dart';
// import '../models/category.dart';

// class CategoryForm extends StatefulWidget {
//   @override
//   _CategoryFormState createState() => _CategoryFormState();
// }

// class _CategoryFormState extends State<CategoryForm> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final CategoryController _categoryController = CategoryController();

//   void _saveCategory() async {
//     if (_formKey.currentState!.validate()) {
//       Category category = Category(id: '', name: _nameController.text, imagUrl: "https://github.com/aMoni3m/e-commerce-Image/blob/main/images/iconCategory/icons8-shoes-64.png?raw=true"
// );
//       await _categoryController.addCategory(category);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Category added successfully!')),
//       );
//       _nameController.clear(); // Clear the input field
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Category'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Category Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a category name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveCategory,
//                 child: Text('Save'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
