import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_extension_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
import 'package:get/get.dart';

import '../../../../analyzer/fix_runtime_configuration.dart';
import '../../../../common/common_function.dart';
import '../controllers/fix_method_controller.dart';
import 'fix_method_view.dart';
import 'fix_select_view.dart';

class FixExtensionView extends StatelessWidget {
  final FixExtensionController controller;
  const FixExtensionView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复扩展配置'),
        actions: [
          IconButton(
            onPressed: () => controller.save(),
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('扩展类型:'),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '请输入扩展类型',
                  ),
                  controller: controller.extensionNameController,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: FixTabView(controller.tabController),
            ),
          ),
        ],
      ),
    );
  }
}
