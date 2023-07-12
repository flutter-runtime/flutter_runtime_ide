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
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FixTabView(controller.tabController),
      ),
    );
  }
}
