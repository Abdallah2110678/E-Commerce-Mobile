// notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/controllers/notification_controller.dart';
import 'package:mobile_project/screens/home/account_settings.dart';
import 'package:mobile_project/utils/constants/sizes.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.spaceBtwItems),

            // Settings List
            Obx(() => AccountSettings(
                  icon: Iconsax.notification,
                  title: 'Push Notifications',
                  subtitle: 'Enable push notifications',
                  trailing: Switch(
                    value: controller.pushNotifications.value,
                    onChanged: (_) =>
                        controller.toggleSetting(controller.pushNotifications),
                  ),
                )),

            Obx(() => AccountSettings(
                  icon: Iconsax.message,
                  title: 'Email Notifications',
                  subtitle: 'Enable email updates',
                  trailing: Switch(
                    value: controller.emailNotifications.value,
                    onChanged: (_) =>
                        controller.toggleSetting(controller.emailNotifications),
                  ),
                )),

            Obx(() => AccountSettings(
                  icon: Iconsax.discount_shape,
                  title: 'New Offers',
                  subtitle: 'Be the first to know about new deals',
                  trailing: Switch(
                    value: controller.newOffers.value,
                    onChanged: (_) =>
                        controller.toggleSetting(controller.newOffers),
                  ),
                )),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveSettings,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
