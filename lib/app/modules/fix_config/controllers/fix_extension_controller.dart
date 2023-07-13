import 'package:analyzer/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_extension_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';

import '../views/fix_method_view.dart';
import '../views/fix_parameter_view.dart';
import 'fix_file_controller.dart';
import 'fix_method_controller.dart';
import 'fix_parameter_controller.dart';

class FixExtensionController extends GetxController {
  final AnalyzerExtensionCache cache;

  // 是否隐藏
  var isEnable = true.obs;

  late FixSelectController<AnalyzerMethodCache> selectMethodController;
  late FixSelectController<AnalyzerPropertyAccessorCache> selectFieldController;

  final TextEditingController extensionNameController = TextEditingController();

  late FixTabController tabController;

  FixExtensionController(this.cache) {
    isEnable.value = cache.isEnable;
    selectMethodController = FixSelectController(cache.methods);
    selectFieldController = FixSelectController(cache.fields);
    extensionNameController.text = cache.extensionName ?? '';

    tabController = FixTabController([
      FixTabViewSource(
        'method',
        selectMethodController,
        onTap: (item) => Unwrap(item).map(
          (e) => _showFixMethodView(e as AnalyzerMethodCache),
        ),
      ),
      FixTabViewSource(
        'field',
        selectFieldController,
        onTap: (item) => Unwrap(item).map(
          (e) => _showFixParameterView(e as AnalyzerPropertyAccessorCache),
        ),
      ),
    ]);
  }

  save() {
    cache.extensionName = extensionNameController.text;
    eventBus.fire(SaveFileCacheEvent());
  }

  setOn(bool isOn) {
    isEnable.value = isOn;
    cache.isEnable = isOn;
  }

  _showFixMethodView(AnalyzerMethodCache cache) {
    Get.dialog(Dialog(child: FixMethodView(FixMethodController(cache))));
  }

  _showFixParameterView(AnalyzerPropertyAccessorCache cache) {
    Get.dialog(Dialog(child: FixParameterView(FixParameterController(cache))));
  }
}
