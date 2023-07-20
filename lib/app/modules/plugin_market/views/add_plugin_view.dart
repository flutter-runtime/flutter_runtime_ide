import 'package:dcm/dcm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/add_plugin_controller.dart';
import 'package:get/get.dart';

class AddPluginView extends StatelessWidget {
  final AddPluginController controller;
  const AddPluginView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, minHeight: 200),
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoListTile(
                title: TextField(
                  decoration: const InputDecoration(labelText: '请输入插件仓库地址'),
                  controller: controller.urlController,
                ),
              ),
              if (!controller.isLocalPlugin.value) const SizedBox(height: 10),
              if (!controller.isLocalPlugin.value)
                CupertinoListTile(
                  title: TextField(
                    decoration:
                        const InputDecoration(labelText: '请输入branch|tag|ref'),
                    controller: controller.refController,
                  ),
                ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('是否本地仓库地址'),
                value: controller.isLocalPlugin.value,
                onChanged: (value) => controller.isLocalPlugin.toggle(),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('是否覆盖安装'),
                value: controller.isOverwrite.value,
                onChanged: (value) => controller.isOverwrite.toggle(),
              ),
              const SizedBox(height: 10),
              CupertinoListTile(
                title: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('添加'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
