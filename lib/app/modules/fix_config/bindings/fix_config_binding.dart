import 'package:get/get.dart';


import '../controllers/fix_runtime_config_controller.dart';

class FixConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FixRuntimeConfigController>(
      () => FixRuntimeConfigController(),
    );
  }
}
