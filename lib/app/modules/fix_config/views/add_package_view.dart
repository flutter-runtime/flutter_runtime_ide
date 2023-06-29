import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';

import 'package:get/get.dart';
import 'package:menu_button/menu_button.dart';

import '../controllers/fix_config_controller.dart';

class AddPackageView extends StatelessWidget {
  const AddPackageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixConfigController());
    return Container(
      padding: const EdgeInsets.all(15),
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('添加包名'),
          TextField(
            decoration: const InputDecoration(hintText: '搜索包名'),
            controller: controller.packageNameController,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择包名'),
              const SizedBox(width: 15),
              Expanded(
                child: Obx(() {
                  return MenuButton(
                    items: controller.packageInfos.value,
                    itemBuilder: (e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(e.name),
                    ),
                    onItemSelected: (value) {
                      controller.currentPackageInfo.value = value;
                    },
                    child: Obx(
                      () => Container(
                        // padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                        ),
                        child: Row(
                          children: [
                            Text(controller.currentPackageInfo.value?.name ??
                                ''),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }
}
