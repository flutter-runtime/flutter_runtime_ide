import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixFileController extends GetxController {
  final FixConfig config;
  final String fullPath;
  late FixSelectController<FixClassConfig> selectClassController;
  late FixSelectController<FixExtensionConfig> selectExtensionController;
  late FixSelectController<FixImportConfig> selectImportController;
  late SomeResolvedLibraryResult? _library;
  FixFileController(this.config, this.fullPath) {
    selectClassController = FixSelectController(config.classs);
    selectExtensionController = FixSelectController(config.extensions);
    selectImportController = FixSelectController(config.imports);
    _library = AnalyzerPackageManager().getResult(fullPath);
  }

  List<FixClassConfig> get allEmptyClassConfig {
    return allClasss.map((e) => FixClassConfig()..name = e.name).toList();
  }

  List<FixExtensionConfig> get allEmptyExtensionConfig {
    return allExtensions
        .map((e) => FixExtensionConfig()..name = e.name!)
        .toList();
  }

  List<FixImportConfig> get allEmptyImportConfig {
    var index = 0;
    return allImports.map((e) {
      final config = FixImportConfig()
        ..path = e.uri.stringValue ?? ''
        ..index = index;
      index++;
      return config;
    }).toList();
  }

  void addClassConfig(FixClassConfig result) {
    selectClassController.add(result);
    config.classs = selectClassController.items;
  }

  void addExtensionConfig(FixExtensionConfig result) {
    selectExtensionController.add(result);
    config.extensions = selectExtensionController.items;
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

  List<ExtensionElement> get allExtensions {
    if (_library is! ResolvedLibraryResult) return [];
    ResolvedLibraryResult result = _library as ResolvedLibraryResult;
    return result.element.units
        .map((e) => e.extensions)
        .expand((e) => e)
        .toList()
        .where(
            (element) => element.name != null && !element.name!.startsWith('_'))
        .toList();
  }

  List<ImportDirective> get allImports {
    if (_library is! ResolvedLibraryResult) return [];
    ResolvedLibraryResult result = _library as ResolvedLibraryResult;
    return result.units
        .map((e) => e.unit.directives)
        .expand((e) => e)
        .toList()
        .whereType<ImportDirective>()
        .toList();
  }

  ClassElement? getClassElement(String className) {
    return allClasss.firstWhereOrNull((element) => element.name == className);
  }

  ExtensionElement? getExtensionElement(String name) {
    return allExtensions.firstWhereOrNull((element) => element.name == name);
  }

  ImportDirective? getImportElement(String path) {
    return allImports.firstWhereOrNull((element) {
      return element.uri.stringValue == path;
    });
  }

  void addImportConfig(FixImportConfig result) {
    selectImportController.add(result);
    config.imports = selectImportController.items;
  }
}
