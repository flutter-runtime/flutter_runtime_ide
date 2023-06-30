import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixClassController extends GetxController {
  final FixConfig config;
  late FixSelectController<FixClassConfig> selectController;
  FixClassController(this.config) {
    selectController = FixSelectController(config.classs.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }

  void addClassConfig(String name) {
    final config = FixClassConfig()..name = name;
    this.config.classs.add(config);
    selectController.updateItems(this.config.classs.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }
}
