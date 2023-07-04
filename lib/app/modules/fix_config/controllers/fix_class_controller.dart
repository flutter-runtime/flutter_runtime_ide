import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixClassController extends GetxController {
  final FixClassConfig config;
  final ClassElement element;
  late FixSelectController<FixMethodConfig> selectController;
  FixClassController(this.config, this.element) {
    selectController = FixSelectController(config.methods);
  }

  List<MethodElement> get allMethod {
    return element.methods.where((element) => !element.name.isPrivate).toList();
  }

  void addConfig(FixMethodConfig result) {
    selectController.add(result);
    config.methods = selectController.items;
  }

  MethodElement? getMethod(String name) {
    return allMethod.firstWhereOrNull((element) => element.name == name);
  }
}
