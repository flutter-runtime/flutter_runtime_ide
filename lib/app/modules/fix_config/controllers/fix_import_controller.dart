import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixImportController extends GetxController {
  final FixImportConfig config;
  final ImportDirective importDirective;
  late FixSelectController<ImportValue> selectShowController;
  late FixSelectController<ImportValue> selectHideController;

  FixImportController(this.config, this.importDirective) {
    selectShowController = FixSelectController(
        config.showNames.map((e) => ImportValue(e)).toList());
    selectHideController = FixSelectController(
        config.hideNames.map((e) => ImportValue(e)).toList());
  }

  void addHideValue(String value) {
    selectHideController.add(ImportValue(value));
    config.hideNames = selectHideController.items.map((e) => e.name).toList();
  }

  void addShowValue(String value) {
    selectShowController.add(ImportValue(value));
    config.showNames = selectShowController.items.map((e) => e.name).toList();
  }
}

class ImportValue extends FixSelectItem {
  @override
  final String name;
  ImportValue(this.name);
}
