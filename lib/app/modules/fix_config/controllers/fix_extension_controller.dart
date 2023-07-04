import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

class FixExtensionController extends GetxController {
  final FixExtensionConfig config;
  final ExtensionElement element;

  // 是否隐藏
  var isHide = false.obs;

  FixExtensionController(this.config, this.element) {
    isHide.value = !config.isEnable;
  }

  void setIsHide(bool isHide) {
    this.isHide.value = isHide;
    config.isEnable = !isHide;
  }
}
