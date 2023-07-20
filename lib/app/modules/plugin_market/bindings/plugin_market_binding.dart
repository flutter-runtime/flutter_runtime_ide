import 'package:get/get.dart';

import '../controllers/plugin_market_controller.dart';

class PluginMarketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PluginMarketController>(
      () => PluginMarketController(),
    );
  }
}
