import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_project/screens/home/nav.dart';
import 'package:mobile_project/screens/styles/spacing_styles.dart';
import 'package:mobile_project/controllers/login_controller.dart';
import 'package:mobile_project/utils/constants/colors.dart';
import 'package:mobile_project/utils/constants/image_setting.dart';
import 'package:mobile_project/utils/constants/sizes.dart';
import 'package:mobile_project/utils/constants/text_strings.dart';
import 'package:mobile_project/utils/helpers/helper_functions.dart';
import 'package:mobile_project/utils/validators/validation.dart';
import 'package:mobile_project/screens/signup/signup.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(LoginController());

    controller.resetFields();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyles.paddingWithAppBarHeight,
          child: Column(
            children: [
              /////logo, title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    height: 150,
                    image: AssetImage(
                        dark ? TImages.lightAppLogo : TImages.darkAppLogo),
                  ),
                  Text(TTexts.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: TSizes.sm),
                  Text(TTexts.loginSubTitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              ////form
              Form(
                key: controller.loginFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: TSizes.spaceBtwSections),
                  child: Column(
                    children: [
                      ///Email
                      TextFormField(
                        controller: controller.email,
                        validator: (value) => TValidator.validateEmail(value),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.direct_right),
                            labelText: TTexts.email),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields),

                      ///Password
                      Obx(
                        () => TextFormField(
                          controller: controller.password,
                          validator: (value) =>
                              TValidator.validatePassword(value),
                          obscureText: controller.hidePassword.value,
                          decoration: InputDecoration(
                            labelText: TTexts.password,
                            prefixIcon: const Icon(Iconsax.password_check),
                            suffixIcon: IconButton(
                                onPressed: () => controller.hidePassword.value =
                                    !controller.hidePassword.value,
                                icon: Icon(controller.hidePassword.value
                                    ? Iconsax.eye_slash
                                    : Iconsax.eye)),
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwInputFields / 2),

                      ///Remember me & forget password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //remember me
                          Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (Value) => controller.rememberMe
                                        .value = !controller.rememberMe.value),
                              ),
                              const Text(TTexts.rememberMe),
                            ],
                          ),
                          //forget password
                          TextButton(
                            onPressed: () {},
                            child: const Text(TTexts.forgetPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),

                      ///sign in button
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () async {
                                // Check if the form is valid
                                if (controller.loginFormKey.currentState!
                                    .validate()) {
                                  try {
                                    await controller.emailAndPasswordSignIn();

                                    Get.to(() => Nav());
                                  } catch (e) {
                                    print('Sign-in failed: $e');
                                  }
                                } else {
                                  print(
                                      'Please enter valid email and password');
                                }
                              },
                              child: const Text(TTexts.signIn))),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      ///create account button
                      SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () =>
                                  Get.to(() => const SignupScreen()),
                              child: const Text(TTexts.createAccount))),
                    ],
                  ),
                ),
              ),
              ////divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Divider(
                        color: dark ? TColors.darkGrey : TColors.grey,
                        thickness: 0.5,
                        indent: 60,
                        endIndent: 5),
                  ),
                  Text(TTexts.orSignInWith.capitalize!,
                      style: Theme.of(context).textTheme.labelMedium),
                  Flexible(
                    child: Divider(
                        color: dark ? TColors.darkGrey : TColors.grey,
                        thickness: 0.5,
                        indent: 5,
                        endIndent: 60),
                  ),
                ],
              ),
              const SizedBox(width: TSizes.spaceBtwSections),

              ///footer
              socialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class socialButtons extends StatelessWidget {
  const socialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () => controller.googleSignIn(),
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.google),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
