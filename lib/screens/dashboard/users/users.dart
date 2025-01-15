import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/screens/dashboard/users/updateuser.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserController _controller = Get.put(UserController()); // Bind the controller
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await _controller.loadUsers();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by first name or last name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),

            // DataTable
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Obx(() {
                      if (_controller.users.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey[200],
                          ),
                          columns: const [
                            DataColumn(
                                label: Text('First Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Last Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Role',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Action',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: _controller.users
                              .where((user) =>
                                  user.firstName
                                      .toLowerCase()
                                      .contains(_searchQuery) ||
                                  user.lastName
                                      .toLowerCase()
                                      .contains(_searchQuery))
                              .map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user.firstName)),
                              DataCell(Text(user.lastName)),
                              DataCell(Text(user.role.toValue())),
                              DataCell(
                                Row(
                                  children: [
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        // Navigate to the UpdateUserForm with the selected user
                                        Get.to(() => UpdateUserForm(user: user));
                                      },
                                    ),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteUser(user),
                                    ),
                                    // Promote to Admin Button
                                    if (user.role.toValue() != 'Admin')
                                      IconButton(
                                        icon: const Icon(Icons.upgrade,
                                            color: Colors.green),
                                        tooltip: 'Promote to Admin',
                                        onPressed: () => _promoteUserToAdmin(user),
                                      ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
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
      await _controller.deleteUser(user.id);
      _controller.users.remove(user);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteUserToAdmin(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Admin'),
        content: const Text('Are you sure you want to promote this user to Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promote'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.promoteUserToAdmin(user.id);
    }
  }
}
