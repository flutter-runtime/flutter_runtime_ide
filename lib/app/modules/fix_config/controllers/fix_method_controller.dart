import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_method_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:get/get.dart';

import 'fix_select_controller.dart';

class FixMethodController extends GetxController {
  final AnalyzerMethodCache cache;

  late FixSelectController<AnalyzerPropertyAccessorCache> selectController;

  var isShow = false.obs;

  FixMethodController(this.cache) {
    selectController = FixSelectController(cache.parameters);
    isShow.value = cache.isEnable;
  }
}
