import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/fix_parameter_controller.dart';

class FixParameterView extends StatelessWidget {
  final FixParameterController controller;
  const FixParameterView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复参数配置'),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('参数类型:'),
                const SizedBox(width: 15),
                Expanded(
                    child: TextField(
                  decoration: const InputDecoration(hintText: '输入参数类型'),
                  controller: controller.typeController,
                )),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
