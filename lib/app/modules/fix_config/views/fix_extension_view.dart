import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_extension_controller.dart';
import 'package:get/get.dart';

class FixExtensionView extends StatelessWidget {
  final FixExtensionController controller;
  const FixExtensionView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('修复扩展配置')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              leading: const Text('是否隐藏'),
              trailing: Obx(
                () => Switch(
                  value: controller.isHide.value,
                  onChanged: (isOn) => controller.setIsHide(isOn),
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
