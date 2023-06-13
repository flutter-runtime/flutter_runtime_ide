import 'package:get/get.dart';

import '../controllers/progress_hud_view_controller.dart';

class ProgressHudViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressHudViewController>(
      () => ProgressHudViewController(),
    );
  }
}
