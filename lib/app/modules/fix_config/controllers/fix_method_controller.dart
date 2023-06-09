import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixMethodController extends GetxController {
  final FixMethodConfig config;
  final FunctionTypedElement element;
  late FixSelectController<FixParameterConfig> selectController;

  var isShow = false.obs;

  FixMethodController(this.config, this.element) {
    selectController = FixSelectController(config.parameters);
    isShow.value = config.isEnable;
  }

  List<ParameterElement> get allParameter {
    return element.parameters
        .where((element) => !element.name.isPrivate)
        .toList();
  }

  void addConfig(FixParameterConfig result) {
    selectController.add(result);
    config.parameters = selectController.items;
  }

  setIsShow(bool isOn) {
    isShow.value = isOn;
    config.isEnable = isOn;
  }
}
