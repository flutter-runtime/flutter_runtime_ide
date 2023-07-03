import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

class FixExtensionController extends GetxController {
  final FixRuntimeConfiguration configuration;
  final ExtensionElement element;
  FixExtensionController(this.configuration, this.element);
}
