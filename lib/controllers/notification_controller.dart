// notification_controller.dart
import 'package:get/get.dart';
import 'package:mobile_project/utils/popups/loaders.dart';

class NotificationController extends GetxController {
  final RxBool pushNotifications = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool orderUpdates = true.obs;
  final RxBool newOffers = true.obs;
  final RxBool deliveryUpdates = true.obs;

  void toggleSetting(RxBool setting) {
    setting.value = !setting.value;
  }

  Future<void> saveSettings() async {
    try {
      // Implement your save logic here
      TLoaders.successSnackBar(
        title: 'success',
        message: 'Notification settings updated',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
