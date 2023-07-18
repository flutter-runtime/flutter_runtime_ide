import 'package:analyzer/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_class_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_method_controller.dart';
import 'package:get/get.dart';

import '../views/fix_method_view.dart';
import '../views/fix_tab_view.dart';
import 'fix_select_controller.dart';

class FixClassController extends GetxController {
  final AnalyzerClassCache cache;
  late FixTabController tabController;
  late FixSelectController<AnalyzerMethodCache> selectMethodController;
  late FixSelectController<AnalyzerMethodCache> selectConstructorController;
  late FixSelectController<AnalyzerPropertyAccessorCache> selectFieldController;
  var isEnable = false.obs;
  FixClassController(this.cache) {
    selectMethodController = FixSelectController(cache.methods);
    selectConstructorController = FixSelectController(cache.constructors);
    selectFieldController = FixSelectController(cache.fields);
    isEnable.value = cache.isEnable;
    tabController = FixTabController([
      FixTabViewSource(
        'method',
        selectMethodController,
        onTap: (item) => Unwrap(item).map((e) {
          return _showFixMethodView(e as AnalyzerMethodCache);
        }),
      ),
      FixTabViewSource(
        'constructor',
        selectConstructorController,
      ),
      FixTabViewSource(
        'field',
        selectFieldController,
      )
    ]);
  }

  _showFixMethodView(AnalyzerMethodCache cache) {
    Get.dialog(Dialog(child: FixMethodView(FixMethodController(cache))));
  }
}
