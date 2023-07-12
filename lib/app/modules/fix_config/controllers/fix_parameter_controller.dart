import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_file_controller.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';

class FixParameterController extends GetxController {
  final AnalyzerPropertyAccessorCache cache;

  final TextEditingController typeController = TextEditingController();

  FixParameterController(this.cache) {
    typeController.text = cache.asName ?? '';
  }

  save() {
    cache.asName = typeController.text.isEmpty ? null : typeController.text;
    eventBus.fire(SaveFileCacheEvent());
  }
}
