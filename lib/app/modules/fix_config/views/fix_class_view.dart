import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import '../../../../analyzer/fix_runtime_configuration.dart';
import '../controllers/fix_method_controller.dart';
import '../controllers/fix_class_controller.dart';
import 'fix_method_view.dart';

class FixClassView extends StatelessWidget {
  final FixClassController controller;
  const FixClassView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复方法配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _addMethodConfig(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FixSelectView(
          controller: controller.selectController,
          onTap: (item) => Unwrap(item).map((e) => _showFixParameterView(e)),
        ),
      ),
    );
  }

  _showFixParameterView(FixMethodConfig config) async {
    final element = this.controller.getMethod(config.name);
    if (element == null) return;
    final controller = FixMethodController(config, element);
    Get.dialog(Dialog(child: FixMethodView(controller)));
  }

  _addMethodConfig() async {
    final items = controller.allMethod
        .map((e) => FixMethodConfig()..name = e.name)
        .toList();
    final result = await showSelectItemDialog(items);
    if (result == null) return;
    controller.addConfig(result);
  }
}
