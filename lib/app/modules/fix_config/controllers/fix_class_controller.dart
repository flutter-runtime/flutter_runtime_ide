import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixClassController extends GetxController {
  final FixConfig config;
  final String fullPath;
  late FixSelectController<FixClassConfig> selectController;
  late SomeResolvedLibraryResult? _library;
  FixClassController(this.config, this.fullPath) {
    selectController = FixSelectController(config.classs);
    _library = AnalyzerPackageManager().getResult(fullPath);
  }

  List<FixClassConfig> get allEmptyClassConfig {
    return allClasss.map((e) => FixClassConfig()..name = e.name).toList();
  }

  void addConfig(FixClassConfig result) {
    selectController.add(result);
  }

  List<ClassElement> get allClasss {
    if (_library is! ResolvedLibraryResult) return [];
    ResolvedLibraryResult result = _library as ResolvedLibraryResult;
    return result.element.units
        .map((e) => e.classes)
        .expand((e) => e)
        .toList()
        .where((element) => !element.name.startsWith('_'))
        .toList();
  }

  ClassElement? getElement(String className) {
    return allClasss.firstWhereOrNull((element) => element.name == className);
  }
}
