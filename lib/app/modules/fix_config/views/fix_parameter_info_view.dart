import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_parameter_info_controller.dart';
import 'package:get/get.dart';

class FixParameterInfoView extends StatelessWidget {
  final FixParameterInfoController controller;
  const FixParameterInfoView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(hintText: '输入参数类型'),
            controller: controller.typeController,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('保存'),
            ),
          )
        ],
      ),
    );
  }
}
