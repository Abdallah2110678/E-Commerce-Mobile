// import 'package:flutter/material.dart';
// import '../controllers/category_controller.dart';
// import '../models/category.dart';

// class CategoryManagementPage extends StatefulWidget {
//   @override
//   _CategoryManagementPageState createState() => _CategoryManagementPageState();
// }

// class _CategoryManagementPageState extends State<CategoryManagementPage> {
//   final CategoryController _categoryController = CategoryController();
//   late Future<List<Category>> _categoriesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _refreshCategories();
//   }

//   void _refreshCategories() {
//     setState(() {
//       _categoriesFuture = _categoryController.fetchCategories();
//     });
//   }

//   // Show Add/Edit Category Dialog
//   void _showCategoryDialog({Category? category}) {
//     final TextEditingController nameController = TextEditingController(
//       text: category?.name ?? '',
//     );
//     final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(category == null ? 'Add Category' : 'Edit Category'),
//           content: Form(
//             key: formKey,
//             child: TextFormField(
//               controller: nameController,
//               decoration: InputDecoration(
//                 labelText: 'Category Name',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.trim().isEmpty) {
//                   return 'Please enter a category name';
//                 }
//                 return null;
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (formKey.currentState!.validate()) {
//                   try {
//                     if (category == null) {
//                       // Add new category
//                       await _categoryController.addCategory(
//                         Category(id: '', name: nameController.text.trim(), imagUrl: 'https://github.com/aMoni3m/e-commerce-Image/blob/main/images/iconCategory/icons8-shoes-64.png?raw=true',),
//                       );
//                     } else {
//                       // Update existing category
//                       await _categoryController.updateCategory(
//                         category.copyWith(name: nameController.text.trim()),
//                       );
//                     }
//                     _refreshCategories();
//                     Navigator.of(context).pop();
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: ${e.toString()}')),
//                     );
//                   }
//                 }
//               },
//               child: Text('Save'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Delete Category Method
//   void _deleteCategory(Category category) async {
//     bool deleted = await _categoryController.deleteCategory(category.id);
    
//     if (deleted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Category deleted successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       _refreshCategories();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Cannot delete category. It is in use by some products.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Category Management'),
//         centerTitle: true,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showCategoryDialog(),
//         child: Icon(Icons.add),
//         tooltip: 'Add New Category',
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FutureBuilder<List<Category>>(
//           future: _categoriesFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children:[
//                     Icon(Icons.category_outlined, size: 100, color: Colors.grey),
//                     SizedBox(height: 20),
//                     Text(
//                       'No categories found',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             final categories = snapshot.data!;

//             return LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Container(
//                     width: MediaQuery.of(context).orientation == Orientation.portrait 
//                         ? constraints.maxWidth 
//                         : constraints.maxWidth * 0.9,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.2),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: DataTable(
//                         columnSpacing: 20,
//                         headingRowColor: MaterialStateColor.resolveWith(
//                           (states) => Colors.blue[50]!,
//                         ),
//                         dividerThickness: 1,
//                         columns: [
//                           DataColumn(
//                             label: Text(
//                               '#', 
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold, 
//                                 color: Colors.blue[800]
//                               ),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'Name', 
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold, 
//                                 color: Colors.blue[800]
//                               ),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Text(
//                               'Actions', 
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold, 
//                                 color: Colors.blue[800]
//                               ),
//                             ),
//                           ),
//                         ],
//                         rows: categories.asMap().entries.map((entry) {
//                           int index = entry.key;
//                           Category category = entry.value;
//                           return DataRow(
//                             color: MaterialStateColor.resolveWith(
//                               (states) => index % 2 == 0 
//                                   ? Colors.white 
//                                   : Colors.blue[50]!,
//                             ),
//                             cells: [
//                               DataCell(Text('${index + 1}')),
//                               DataCell(Text(category.name)),
//                               DataCell(
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: Icon(Icons.edit, color: Colors.blue),
//                                       onPressed: () => _showCategoryDialog(category: category),
//                                       tooltip: 'Edit Category',
//                                     ),
//                                     IconButton(
//                                       icon: Icon(Icons.delete, color: Colors.red),
//                                       onPressed: () => _deleteCategory(category),
//                                       tooltip: 'Delete Category',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }