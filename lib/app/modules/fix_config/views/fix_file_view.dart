import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_class_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_file_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_class_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';

import '../../../../common/common_function.dart';
import 'add_name_view.dart';

class FixFileView extends StatelessWidget {
  final FixFileController controller;
  const FixFileView({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddFileView(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FixSelectView(
        controller: controller.selectController,
        onTap: (item) => Unwrap(item).map((e) => _showFixClassView(e)),
      ),
    );
  }

  _showFixClassView(FixConfig config) async {
    final fullPath = this.controller.getFullPath(config);
    if (fullPath == null) return;
    final controller = FixClassController(config, fullPath);
    Get.dialog(Dialog(child: FixClassView(controller: controller)));
  }

  _showAddFileView() async {
    final paths = AnalyzerPackageManager()
        .getPackageLibraryPaths(controller.packageInfo?.packagePath ?? '');
    if (paths.isEmpty) {
      Get.snackbar('未分析！', '请先分析库: ${controller.configuration.name}');
      return;
    }
    final result = await showSelectItemDialog(paths
        .map((e) {
          return libraryPath(e);
        })
        .whereType<String>()
        .map((e) {
          return _AnalysisPath(e);
        })
        .toList());
    if (result == null) return;
    controller.addConfig(result.name);
  }
}

class _AnalysisPath extends FixSelectItem {
  @override
  final String name;

  _AnalysisPath(this.name);
}
