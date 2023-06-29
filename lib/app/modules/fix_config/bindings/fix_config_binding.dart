import 'package:get/get.dart';

import '../controllers/fix_config_controller.dart';

class FixConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FixConfigController>(
      () => FixConfigController(),
    );
  }
}
