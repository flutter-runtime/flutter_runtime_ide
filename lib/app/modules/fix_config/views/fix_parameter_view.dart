import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';
import '../../../../common/common_function.dart';
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
    final items = controller.allParameter
        .map((e) => FixParameterConfig()..name = e.name)
        .toList();
    final result = await showSelectItemDialog(items);
    if (result == null) return;
    controller.addConfig(result);
  }
}
