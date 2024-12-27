import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/screens/home/account_settings.dart';
import 'package:mobile_project/screens/home/appbar.dart';
import 'package:mobile_project/screens/home/home.dart';
import 'package:mobile_project/screens/home/profile/profile.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/widgets/images/circular_image.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          ///header
          children: [
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  //appbar
                  TAppbar(
                    title: Text('Account',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .apply(color: Colors.white)),
                  ),

                  //User profile card
                  userProfileTitle(
                      onPressed: () => Get.to(() => const ProfileScreen())),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            ///body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  //account settings
                  const TSectionHeading(
                      title: 'Account Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  const AccountSettings(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subtitle: 'Set shopping delivery addresses',
                  ),
                  const AccountSettings(
                    icon: Iconsax.shopping_cart,
                    title: 'My Cart',
                    subtitle: 'Add, remove products',
                  ),
                  const AccountSettings(
                      icon: Iconsax.bag_tick,
                      title: 'My Orders',
                      subtitle: 'In-progress and Completed Orders'),
                  const AccountSettings(
                      icon: Iconsax.bank,
                      title: 'Bank Account',
                      subtitle: 'Withdraw balance to registered bank account'),
                  const AccountSettings(
                      icon: Iconsax.discount_shape,
                      title: 'My Coupons',
                      subtitle: 'List of all the discounted coupons'),
                  const AccountSettings(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subtitle: 'Set any kind of notification message'),
                  const AccountSettings(
                      icon: Iconsax.security_card,
                      title: 'Account Privacy',
                      subtitle: 'Manage data usage and connected accounts'),

                  //app settings
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(
                      title: 'App Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const AccountSettings(
                      icon: Iconsax.document_upload,
                      title: 'Load Data',
                      subtitle: 'Upload Data to your Cloud Firebase'),
                  AccountSettings(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subtitle: 'Set recommendation based on location',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  AccountSettings(
                    icon: Iconsax.security_user,
                    title: 'Safe Mode',
                    subtitle: 'Search result is safe for all ages',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

                  AccountSettings(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subtitle: 'Set image quality to be seen',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

                  //Logout button
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {}, child: const Text('Logout')),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//user profile card
class userProfileTitle extends StatelessWidget {
  const userProfileTitle({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: TCircularImage(
          image: TImages.user, width: 50, height: 50, padding: 0),
      title: Text('Ahmed',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: Colors.white)),
      subtitle: Text('ahmed@gmail.com',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .apply(color: Colors.white)),
      trailing: IconButton(
          onPressed: onPressed,
          icon: const Icon(Iconsax.edit, color: TColors.white)),
    );
  }
}
