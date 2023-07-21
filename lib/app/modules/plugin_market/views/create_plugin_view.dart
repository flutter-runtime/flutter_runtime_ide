import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/create_plugin_controller.dart';
import 'package:get/get.dart';

class CreatePluginView extends StatelessWidget {
  final CreatePluginController controller;
  const CreatePluginView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(
        minWidth: 500,
        minHeight: 200,
        maxWidth: 500,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoListTile(
            title: TextField(
              decoration: const InputDecoration(labelText: '插件名称'),
              controller: controller.nameController,
            ),
          ),
          const SizedBox(height: 10),
          CupertinoListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: '模版工程 Git 仓库的 Http 地址'),
              controller: controller.urlController,
            ),
          ),
          const SizedBox(height: 10),
          CupertinoListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: '自定义对应引用 可以是分支 版本 或者提交'),
              controller: controller.refController,
            ),
          ),
          const SizedBox(height: 10),
          CupertinoListTile(
            title: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('创建'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
