import 'package:analyzer/dart/element/element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_extension_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
import 'package:get/get.dart';

class FixExtensionController extends GetxController {
  final AnalyzerExtensionCache cache;

  // 是否隐藏
  var isHide = false.obs;

  late FixSelectController<AnalyzerMethodCache> selectMethodController;
  late FixSelectController<AnalyzerPropertyAccessorCache> selectFieldController;

  final TextEditingController extensionNameController = TextEditingController();

  late FixTabController tabController;

  FixExtensionController(this.cache) {
    isHide.value = !cache.isEnable;
    selectMethodController = FixSelectController(cache.methods);
    selectFieldController = FixSelectController(cache.fields);
    extensionNameController.text = cache.extensionName ?? '';

    tabController = FixTabController([
      FixTabViewSource(
        'method',
        selectMethodController,
      ),
      FixTabViewSource(
        'field',
        selectFieldController,
      ),
    ]);
  }
}
