import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixExtensionController extends GetxController {
  final FixExtensionConfig config;
  final ExtensionElement element;

  // 是否隐藏
  var isHide = false.obs;

  late FixSelectController<FixMethodConfig> selectMethodController;

  FixExtensionController(this.config, this.element) {
    isHide.value = !config.isEnable;
    selectMethodController = FixSelectController(config.methods);
  }

  List<FixMethodConfig> get allEmptyMethodConfig =>
      allMethod.map((e) => FixMethodConfig()..name = e.name).toList();

  List<MethodElement> get allMethod {
    return element.methods.where((element) => !element.name.isPrivate).toList();
  }

  void setIsHide(bool isHide) {
    this.isHide.value = isHide;
    config.isEnable = !isHide;
  }

  void addConfig(FixMethodConfig result) {
    selectMethodController.add(result);
    config.methods = selectMethodController.items;
  }

  MethodElement? getMethod(String name) {
    return allMethod.firstWhereOrNull((element) => element.name == name);
  }
}
