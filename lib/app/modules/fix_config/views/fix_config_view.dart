import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/add_package_view.dart';

import 'package:get/get.dart';

import '../controllers/fix_config_controller.dart';

class FixConfigView extends GetView<FixConfigController> {
  const FixConfigView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixConfigController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复配置'),
        centerTitle: true,
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () => _showAddPackageView(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Center(
              child: Text(
                '⚠️添加修复配置请确保先生成对应的运行库!',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
            TextField(
              decoration: InputDecoration(hintText: '请输入名字'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPackageView() {
    Get.dialog(
      const Dialog(child: AddPackageView()),
    );
  }
}
