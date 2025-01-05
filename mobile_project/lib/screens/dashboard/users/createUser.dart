import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/models/role.dart';
class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = Get.put(UserController());

  // Text editing controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Example roles
  final List<String> _roles = ['admin','user'];
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    // Fetch users when the page loads
    _userController.loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      _showSnackBar('Please select a role', Colors.red);
      return;
    }

    // Create a new user
    final newUser = UserModel(
      id: '', // Firebase will generate this
      username: _nameController.text,
      email: _emailController.text,
      firstName: _nameController.text.split(' ')[0],
      lastName: _nameController.text.split(' ').length > 1
          ? _nameController.text.split(' ')[1]
          : '',
      phoneNumber: '', // You can add a field for this if needed
      profilePicture: '', // You can add a field for this if needed
      role: _selectedRole == 'admin'
          ? Role.admin : Role.user,
    );

    // Save the user to Firebase
    await _userController.addUser(newUser);
    _showSnackBar('User created successfully', Colors.green);
    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _selectedRole = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Creation Form
              Text(
                'User Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _buildInputDecoration('Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: _buildInputDecoration('Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                decoration: _buildInputDecoration('Select Role'),
                validator: (value) =>
                    value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitUser,
                child: const Text('Create User'),
              ),
              const SizedBox(height: 32),

              // Display Users from Firebase
              Text(
                'Users List',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (_userController.users.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }
                  return ListView.builder(
                    itemCount: _userController.users.length,
                    itemBuilder: (context, index) {
                      final user = _userController.users[index];
                      return ListTile(
                        title: Text(user.fullName),
                        subtitle: Text(user.email),
                        trailing: Text(user.role.toValue()),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}