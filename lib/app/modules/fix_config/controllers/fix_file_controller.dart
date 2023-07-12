import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_class_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_extension_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_import_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_extension_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';

import '../../../../analyzer/cache/analyzer_enum_cache.dart';
import '../../../../analyzer/cache/analyzer_mixin_cache.dart';
import '../../../../analyzer/cache/analyzer_property_accessor_cache.dart';
import '../views/fix_class_view.dart';
import '../views/fix_extension_view.dart';
import '../views/fix_import_view.dart';
import '../views/fix_method_view.dart';
import '../views/fix_parameter_view.dart';
import 'fix_class_controller.dart';
import 'fix_import_controller.dart';
import 'fix_method_controller.dart';
import 'fix_parameter_controller.dart';

class FixFileController extends GetxController {
  final PackageInfo info;
  final String filePath;
  late FixTabController tabController;
  late FixSelectController<AnalyzerClassCache> selectClassController;
  late FixSelectController<AnalyzerExtensionCache> selectExtensionController;
  late FixSelectController<AnalyzerImportCache> selectImportController;
  late FixSelectController<AnalyzerMethodCache> selectMethodController;
  late FixSelectController<AnalyzerEnumCache> selectEnumController;
  late FixSelectController<AnalyzerMixinCache> selectMixinController;
  late FixSelectController<AnalyzerPropertyAccessorCache>
      selectPropertyAccessorController;

  AnalyzerFileCache? _cache;
  StreamSubscription? _subscription;
  FixFileController(this.info, this.filePath) {
    selectClassController = FixSelectController([]);
    selectExtensionController = FixSelectController([]);
    selectImportController = FixSelectController([]);
    selectMethodController = FixSelectController([]);
    selectEnumController = FixSelectController([]);
    selectMixinController = FixSelectController([]);
    selectPropertyAccessorController = FixSelectController([]);

    tabController = FixTabController([
      FixTabViewSource(
        'class',
        selectClassController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixClassView(e as AnalyzerClassCache);
        }),
      ),
      FixTabViewSource(
        'extension',
        selectExtensionController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixExtensionView(e as AnalyzerExtensionCache);
        }),
      ),
      FixTabViewSource(
        'topLevelVariable',
        selectPropertyAccessorController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixParameterView(e as AnalyzerPropertyAccessorCache);
        }),
      ),
      FixTabViewSource(
        'functions',
        selectMethodController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixMethodView(e as AnalyzerMethodCache);
        }),
      ),
      FixTabViewSource('enum', selectEnumController),
      FixTabViewSource('mixin', selectMixinController),
      FixTabViewSource(
        'import',
        selectImportController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixImportView(e as AnalyzerImportCache);
        }),
      ),
    ]);

    showHUD();
    readFileCache();
    hideHUD();

    /// 监听分析配置的改动
    _subscription = eventBus.on<SaveFileCacheEvent>().listen((event) {
      Unwrap(_cache).map((e) async {
        showHUD();
        await AnalyzerPackageManager().saveFileCache(info, e, filePath);
        hideHUD();
      });
    });
  }

  Future<void> readFileCache() async {
    final cache = await AnalyzerPackageManager().readFileCache(info, filePath);
    if (cache == null) return;
    _cache = cache;
    selectClassController.updateItems(cache.classs);
    selectExtensionController.updateItems(cache.extensions);
    selectImportController.updateItems(cache.imports);
    selectMethodController.updateItems(cache.functions);
    selectEnumController.updateItems(cache.enums);
    selectMixinController.updateItems(cache.mixins);
    selectPropertyAccessorController.updateItems(cache.topLevelVariables);
  }

  _showFixClassView(AnalyzerClassCache cache) {
    Get.dialog(Dialog(child: FixClassView(FixClassController(cache))));
  }

  _showFixExtensionView(AnalyzerExtensionCache cache) {
    Get.dialog(Dialog(child: FixExtensionView(FixExtensionController(cache))));
  }

  _showFixParameterView(AnalyzerPropertyAccessorCache cache) {
    Get.dialog(Dialog(child: FixParameterView(FixParameterController(cache))));
  }

  _showFixMethodView(AnalyzerMethodCache cache) {
    Get.dialog(Dialog(child: FixMethodView(FixMethodController(cache))));
  }

  _showFixImportView(AnalyzerImportCache cache) {
    Get.dialog(Dialog(child: FixImportView(FixImportController(cache))));
  }

  @override
  void onClose() {
    super.onClose();
    Unwrap(_subscription).map((e) => e.cancel());
  }
}

class SaveFileCacheEvent {}
