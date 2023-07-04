import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';
import '../../../../common/common_function.dart';
import '../controllers/fix_method_controller.dart';
import '../controllers/fix_parameter_controller.dart';
import 'fix_parameter_view.dart';

class FixMethodView extends StatelessWidget {
  final FixMethodController controller;
  const FixMethodView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复方法配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _addParameterConfig(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FixSelectView(
          controller: controller.selectController,
          onTap: (item) => Unwrap(item).map((e) => _showParameterInfoView(e)),
        ),
      ),
    );
  }

  _addParameterConfig() async {
    final items = controller.allParameter
        .map((e) => FixParameterConfig()
          ..name = e.name
          ..type = '')
        .toList();
    final result = await showSelectItemDialog(items);
    if (result == null) return;
    controller.addConfig(result);
  }

  _showParameterInfoView(FixParameterConfig config) async {
    final controller = FixParameterController(config.type);
    await Get.dialog(
      Dialog(child: FixParameterView(controller: controller)),
    );
    config.type = controller.typeController.text;
  }
}
