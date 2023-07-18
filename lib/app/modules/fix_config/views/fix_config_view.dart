import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_config_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_file_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_file_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';

import '../../../../analyzer/analyzer_package_manager.dart';
import '../../../../common/common_function.dart';
import '../controllers/fix_select_controller.dart';

class FixConfigView extends StatelessWidget {
  final FixConfigController controller;
  const FixConfigView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复库配置'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("名字:"),
                const SizedBox(width: 15),
                Obx(() => Text(controller.name.value)),
              ],
            ),
            Row(
              children: [
                const Text("版本:"),
                const SizedBox(width: 15),
                Obx(() => Text(controller.version.value)),
              ],
            ),
            Divider(color: Colors.blue.shade300),
            Text(
              '文件列表',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: FixSelectView(
                controller: controller.selectController,
                onTap: (item) => Unwrap(item).map((e) => _showFixFileView(e)),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showFixFileView(FixConfigItem item) {
    Get.dialog(Dialog(
      child: FixFileView(
        controller: FixFileController(controller.packageInfo, item.fullPath),
      ),
    ));
  }
}
