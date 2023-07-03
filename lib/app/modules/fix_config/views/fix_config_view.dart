import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_file_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';

import 'package:get/get.dart';

import '../../../../analyzer/analyzer_package_manager.dart';
import '../controllers/fix_config_controller.dart';
import 'fix_file_view.dart';

class FixConfigView extends StatelessWidget {
  final FixConfigController controller;
  const FixConfigView({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await _showAddPackageView();
              if (result != null) {
                controller.addPackage(result);
              }
            },
            icon: const Icon(Icons.add),
          ),
          // 保存按钮
          IconButton(
            onPressed: () => controller.saveConfig(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Center(
              child: Text(
                '⚠️添加修复配置请确保先生成对应的运行库!',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            Expanded(
              child: FixSelectView(
                controller: controller.selectController,
                onTap: (item) => Unwrap(item).map((e) {
                  _showFixFileView(e);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<PackageInfo?> _showAddPackageView() async {
    // 获取全部支持的包
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    return showSelectItemDialog(packages);
  }

  void _showFixFileView(FixRuntimeConfiguration config) {
    final packageInfo = controller.getPackageInfo(config);
    if (packageInfo == null) return;
    final librarys = AnalyzerPackageManager()
        .getPackageLibraryPaths(packageInfo.packagePath);
    if (librarys.isEmpty) {
      Get.snackbar('未分析！', '请先分析库: ${config.name}');
      return;
    }
    Get.dialog(
      Dialog(child: FixFileView(controller: FixFileController(config))),
    );
  }
}
