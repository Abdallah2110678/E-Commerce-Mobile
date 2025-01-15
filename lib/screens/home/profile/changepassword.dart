import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/update_password_controller.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/validators/validation.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdatePasswordController());

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Your password must be at least 8 characters long and contain a mix of letters, numbers, and symbols.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Password fields & button
            Form(
              key: controller.updatePasswordFormKey,
              child: Column(
                children: [
                  // Current Password
                  Obx(
                    () => TextFormField(
                      controller: controller.oldPassword,
                      validator: (value) => TValidator.validatePassword(value),
                      obscureText: controller.hidePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
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
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // New Password
                  Obx(
                    () => TextFormField(
                      controller: controller.newPassword,
                      validator: (value) => TValidator.validatePassword(value),
                      obscureText: controller.hideNewPassword.value,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: () => controller.hideNewPassword.value =
                              !controller.hideNewPassword.value,
                          icon: Icon(controller.hideNewPassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Confirm Password
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPassword,
                      validator: (value) => TValidator.validatePassword(value),
                      obscureText: controller.hideConfirmPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(Iconsax.password_check),
                        suffixIcon: IconButton(
                          onPressed: () => controller.hideConfirmPassword
                              .value = !controller.hideConfirmPassword.value,
                          icon: Icon(controller.hideConfirmPassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updatePassword(),
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
