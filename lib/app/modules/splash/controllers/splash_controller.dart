import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';

class SplashController extends GetxController {
  static const String _onboardingKey = 'hasSeenOnboarding';

  @override
  void onInit() {
    super.onInit();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 2000));

    // Check if user has seen onboarding
    final storageService = Get.find<StorageService>();
    final hasSeenOnboarding = storageService.get<bool>(_onboardingKey) ?? false;

    if (hasSeenOnboarding) {
      Get.offAllNamed('/library');
    } else {
      Get.offAllNamed('/onboarding');
    }
  }
}
