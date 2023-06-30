import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/add_package_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';

import 'package:get/get.dart';

class AddPackageView extends StatelessWidget {
  final AddPackageController controller;
  const AddPackageView({Key? key, required this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(FixConfigController());
    return Container(
      padding: const EdgeInsets.all(15),
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择包名'),
              const SizedBox(width: 15),
              Expanded(
                child: Obx(
                  () => InkWell(
                    onTap: () async {
                      final result = await _selectPackageName();
                      controller.currentPackageInfo.value = result?.item;
                    },
                    child: Container(
                      // padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                      ),
                      child: Row(
                        children: [
                          Text(controller.currentPackageInfo.value?.name ?? ''),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(result: controller.currentPackageInfo.value);
              },
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }

  Future<FixSelectItem<PackageInfo>?> _selectPackageName() async {
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    final controller = FixSelectController(
      packages.map((e) => FixSelectItem(e, e.name)).toList(),
      allowDelete: false,
    );
    return Get.dialog<FixSelectItem<PackageInfo>>(
      Dialog(
        child: FixSelectView(
          controller: controller,
          onTap: (item) {
            Get.back(result: item);
          },
        ),
      ),
    );
  }
}
