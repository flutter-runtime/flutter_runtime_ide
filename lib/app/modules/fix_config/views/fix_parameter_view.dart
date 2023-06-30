import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';
import '../controllers/fix_parameter_controller.dart';
import 'add_name_view.dart';

class FixParameterView extends StatelessWidget {
  final FixParameterController controller;
  const FixParameterView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('FixParameterView'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _addParameterConfig(),
              icon: const Icon(Icons.add),
            )
          ]),
      body: FixSelectView(
        controller: controller.selectController,
        onTap: (item) {},
      ),
    );
  }

  _addParameterConfig() async {
    final config = await Get.dialog<FixParameterConfig>(
      const Dialog(child: _ParameterConfigView()),
    );
    if (config == null) return;
    controller.addParameterConfig(config);
  }
}

class _ParameterConfigView extends StatelessWidget {
  final FixParameterConfig? config;
  const _ParameterConfigView([this.config]);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(hintText: '请输入参数名'),
            controller: nameController,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(hintText: '请输入参数类型'),
            controller: typeController,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: Text(isEdit ? '修改' : '添加'),
              onPressed: () {
                _onSubmit(nameController.text, typeController.text);
              },
            ),
          )
        ],
      ),
    );
  }

  bool get isEdit => config != null;

  void _onSubmit(String name, String type) {
    FixParameterConfig config;
    if (isEdit) {
      config = this.config!;
    } else {
      config = FixParameterConfig();
    }
    config
      ..name = name
      ..type = type;
    Get.back(result: config);
  }
}
