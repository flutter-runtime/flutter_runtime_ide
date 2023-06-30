import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_method_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';

import 'package:get/get.dart';

import '../../../../analyzer/fix_runtime_configuration.dart';
import '../controllers/fix_parameter_controller.dart';
import 'add_name_view.dart';
import 'fix_parameter_view.dart';

class FixMethodView extends StatelessWidget {
  final FixMethodController controller;
  const FixMethodView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixMethodView'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _addMethodConfig(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FixSelectView(
        controller: controller.selectController,
        onTap: (item) => Unwrap(item).map((e) => _showFixParameterView(e.item)),
      ),
    );
  }

  _showFixParameterView(FixMethodConfig config) async {
    final controller = FixParameterController(config);
    Get.dialog(Dialog(child: FixParameterView(controller)));
  }

  _addMethodConfig() async {
    final name = await Get.dialog<String>(
      const Dialog(child: AddNameView(title: '请输入方法名')),
    );
    if (name == null || name.isEmpty) return;
    controller.addMethodConfig(name);
  }
}
