import 'package:get/get.dart';

import '../../collections/controllers/collections_controller.dart';
import '../controllers/library_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LibraryController>(() => LibraryController());
    // Register CollectionsController here instead of in build() method
    // to avoid repeated registration checks during widget rebuilds
    if (!Get.isRegistered<CollectionsController>()) {
      Get.lazyPut<CollectionsController>(() => CollectionsController());
    }
  }
}
