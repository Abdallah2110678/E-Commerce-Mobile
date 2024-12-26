import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_project/screens/styles/spacing_styles.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/text_strings.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/screens/login/login.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onpressed;
  final String image, title, subtitle;

  const SuccessScreen(
      {super.key,
      required this.image,
      required this.title,
      required this.subtitle,
      required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyles.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              ///image
              Image(
                image: AssetImage(TImages.staticSuccessIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///title
              Text(TTexts.yourAccountCreatedTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(TTexts.yourAccountCreatedSubTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      child: const Text(TTexts.tContinue))),
            ],
          ),
        ),
      ),
    );
  }
}
