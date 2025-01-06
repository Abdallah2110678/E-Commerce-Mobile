import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/user_controller.dart';
import 'package:mobile_project/models/usermodel.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/text_strings.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/validators/validation.dart';
import 'package:mobile_project/models/role.dart';

class UpdateUserForm extends StatelessWidget {
  final UserModel user;

  const UpdateUserForm({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(UserController());
    final List<String> roles = Role.values.map((e) => e.toValue()).toList();

    // Pre-fill the form with the current user data
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final phoneNumberController = TextEditingController(text: user.phoneNumber);
    final newPasswordController = TextEditingController();
    final selectedRole = user.role.toValue().obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                'Update User', // Hardcoded string
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form
              Form(
                child: Column(
                  children: [
                    /// First Name and Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            validator: (value) => TValidator.validateEmptyText(
                                'First name', value),
                            decoration: const InputDecoration(
                              labelText: TTexts.firstName,
                              prefixIcon: Icon(Iconsax.user),
                            ),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            validator: (value) => TValidator.validateEmptyText(
                                'Last name', value),
                            decoration: const InputDecoration(
                              labelText: TTexts.lastName,
                              prefixIcon: Icon(Iconsax.user),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Username
                    TextFormField(
                      controller: usernameController,
                      validator: (value) =>
                          TValidator.validateEmptyText('Username', value),
                      decoration: const InputDecoration(
                        labelText: TTexts.username,
                        prefixIcon: Icon(Iconsax.user_edit),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Email
                    TextFormField(
                      controller: emailController,
                      validator: (value) => TValidator.validateEmail(value),
                      decoration: const InputDecoration(
                        labelText: TTexts.email,
                        prefixIcon: Icon(Iconsax.direct),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Phone Number
                    TextFormField(
                      controller: phoneNumberController,
                      validator: (value) =>
                          TValidator.validatePhoneNumber(value),
                      decoration: const InputDecoration(
                        labelText: TTexts.phoneNo,
                        prefixIcon: Icon(Iconsax.call),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Role Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole.value,
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedRole.value = value!;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Iconsax.user_tag),
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a role' : null,
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// New Password (Optional)
                    Obx(
                      () => TextFormField(
                        controller: newPasswordController,
                        obscureText: controller.hidePassword.value,
                        decoration: InputDecoration(
                          labelText: 'New Password (Optional)',
                          prefixIcon: const Icon(Iconsax.password_check),
                          suffixIcon: IconButton(
                            onPressed: () => controller.hidePassword.value =
                                !controller.hidePassword.value,
                            icon: Icon(controller.hidePassword.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Update User Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedUser = UserModel(
                            id: user.id,
                            firstName: firstNameController.text.trim(),
                            lastName: lastNameController.text.trim(),
                            username: usernameController.text.trim(),
                            email: emailController.text.trim(),
                            phoneNumber: phoneNumberController.text.trim(),
                            profilePicture: user.profilePicture,
                            role: Role.fromValue(selectedRole.value),
                          );

                          controller.updateUser(
                            user: updatedUser,
                            newPassword: newPasswordController.text.trim(),
                          );
                        },
                        child: const Text('Update User'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
