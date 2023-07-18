import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_import_cache.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixImportController extends GetxController {
  final AnalyzerImportCache cache;

  FixImportController(this.cache) {}
}

class ImportValue with FixSelectItem {
  @override
  final String name;
  ImportValue(this.name);
}
