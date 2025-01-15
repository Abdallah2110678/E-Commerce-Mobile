import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/update_username_controller.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/validators/validation.dart';

class ChangeUsername extends StatelessWidget {
  const ChangeUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateUsernameController());

    return Scaffold(
      appBar: AppBar(title: const Text('Change Username')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              'Choose a unique username. You can change this at any time.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Username field & button
            Form(
              key: controller.updateUsernameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.username,
                    validator: (value) =>
                        TValidator.validateEmptyText('Username', value),
                    decoration: const InputDecoration(
                      labelText: 'New Username',
                      prefixIcon: Icon(Iconsax.user_edit),
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
                onPressed: () => controller.updateUsername(),
                child: const Text('Update Username'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
