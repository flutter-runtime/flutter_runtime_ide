import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
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
        title: const Text('修复类配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // if (tabViewController.tabController.index == 0) {
              //   _addConstructorConfig();
              // } else if (tabViewController.tabController.index == 1) {
              //   _addMethodConfig();
              // }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Obx(
              () => SwitchListTile(
                title: const Text('是否显示'),
                value: controller.isEnable.value,
                onChanged: (isOn) => {},
              ),
            ),
            const Divider(),
            Expanded(child: FixTabView(controller.tabController))
          ],
        ),
      ),
    );
  }

  _showFixParameterView(FixMethodConfig config,
      [bool isFromConstructor = false]) async {
    // final element = isFromConstructor
    //     ? widget.controller.getConstructor(config.name)
    //     : widget.controller.getMethod(config.name);
    // if (element == null) return;
    // final controller = FixMethodController(config, element);
    // Get.dialog(Dialog(child: FixMethodView(controller)));
  }

  _addMethodConfig() async {
    // final items = widget.controller.allMethod
    //     .map((e) => FixMethodConfig()..name = e.name)
    //     .toList();
    // final result = await showSelectItemDialog(items);
    // if (result == null) return;
    // widget.controller.addMethodConfig(result);
  }

  _addConstructorConfig() async {
    // final items = widget.controller.allConstructor
    //     .map((e) => FixMethodConfig()..name = e.name)
    //     .toList();
    // final result = await showSelectItemDialog(items);
    // if (result == null) return;
    // widget.controller.addConstructorConfig(result);
  }
}
