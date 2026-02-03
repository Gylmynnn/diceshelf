import 'package:get/get.dart';

import '../controllers/highlights_controller.dart';

class HighlightsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HighlightsController>(() => HighlightsController());
  }
}
