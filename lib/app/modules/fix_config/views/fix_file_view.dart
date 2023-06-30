import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_class_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_file_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_class_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';

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
        onTap: (item) => Unwrap(item).map((e) => _showFixClassView(e.item)),
      ),
    );
  }

  _showFixClassView(FixConfig config) async {
    final controller = FixClassController(config);
    Get.dialog(Dialog(child: FixClassView(controller: controller)));
  }

  _showAddFileView() async {
    final path = await Get.dialog<String>(
      const Dialog(child: AddNameView(title: '请输入路径')),
    );
    if (path == null || path.isEmpty) return;

    final paths = AnalyzerPackageManager()
        .getPackageLibraryPaths(controller.packageInfo?.packagePath ?? '');
    if (paths.isEmpty) {
      Get.snackbar('未分析！', '请先分析库: ${controller.configuration.name}');
      return;
    }
    // 是否包含
    final isContains = paths.where((element) {
      return element.endsWith(path);
    }).isNotEmpty;
    // 没有包含提示
    if (!isContains) {
      Get.snackbar('未包含!', '你输入的路径不存在!');
      return;
    }
    controller.addConfig(path);
  }
}
