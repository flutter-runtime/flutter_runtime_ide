import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixClassController extends GetxController {
  final FixClassConfig config;
  final ClassElement element;
  late FixSelectController<FixMethodConfig> selectMethodController;
  late FixSelectController<FixMethodConfig> selectConstructorController;
  var isEnable = false.obs;
  FixClassController(this.config, this.element) {
    selectMethodController = FixSelectController(config.methods);
    selectConstructorController = FixSelectController(config.constructors);
    isEnable.value = config.isEnable;
  }

  List<MethodElement> get allMethod {
    return element.methods.where((element) => !element.name.isPrivate).toList();
  }

  List<ConstructorElement> get allConstructor {
    return element.constructors
        .where((element) => !element.name.isPrivate)
        .toList();
  }

  void addMethodConfig(FixMethodConfig result) {
    selectMethodController.add(result);
    config.methods = selectMethodController.items;
  }

  void addConstructorConfig(FixMethodConfig result) {
    selectConstructorController.add(result);
    config.constructors = selectConstructorController.items;
  }

  MethodElement? getMethod(String name) {
    return allMethod.firstWhereOrNull((element) => element.name == name);
  }

  ConstructorElement? getConstructor(String name) {
    return allConstructor.firstWhereOrNull((element) => element.name == name);
  }

  setEnable(bool isEnable) {
    this.isEnable.value = isEnable;
    config.isEnable = isEnable;
  }
}
