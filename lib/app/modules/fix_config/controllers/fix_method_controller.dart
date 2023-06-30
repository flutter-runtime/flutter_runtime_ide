import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixMethodController extends GetxController {
  final FixClassConfig config;
  late FixSelectController<FixMethodConfig> selectController;
  FixMethodController(this.config) {
    selectController = FixSelectController(config.methods.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }

  void addMethodConfig(String name) {
    final config = FixMethodConfig()..name = name;
    this.config.methods.add(config);
    selectController.updateItems(this.config.methods.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }
}
