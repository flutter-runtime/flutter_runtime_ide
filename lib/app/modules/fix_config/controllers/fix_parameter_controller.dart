import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixParameterController extends GetxController {
  final FixMethodConfig config;
  late FixSelectController<FixParameterConfig> selectController;

  FixParameterController(this.config) {
    selectController = FixSelectController(config.parameters.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }

  void addParameterConfig(FixParameterConfig config) {
    this.config.parameters.add(config);
    selectController.updateItems(this.config.parameters.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());
  }
}
