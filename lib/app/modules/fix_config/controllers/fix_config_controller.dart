import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../data/package_config.dart';

class FixConfigController extends GetxController {
  TextEditingController packageNameController = TextEditingController();

  // var packageInfos = <FixRuntimeConfiguration>[].obs;
  Rx<PackageInfo?> currentPackageInfo = Rx(null);

  late FixSelectController<FixRuntimeConfiguration> selectController;

  FixConfigController() {
    final configs = AnalyzerPackageManager().fixRuntimeConfiguration;
    final packageInfos = configs
        .map((e) {
          final packages =
              AnalyzerPackageManager().packageConfig?.packages ?? [];
          final result = packages.firstWhereOrNull((element) {
            return '${e.name}-${e.version}' == basename(element.rootUri);
          });
          return result != null ? e : null;
        })
        .whereType<FixRuntimeConfiguration>()
        .toList();

    selectController = FixSelectController(packageInfos.map((e) {
      return FixSelectItem(e, e.name);
    }).toList());

    packageNameController.addListener(() {
      final packageName = packageNameController.text;
      if (packageName.isEmpty) {
        return;
      }
      // currentPackageInfo.value = packageInfos
      //     .firstWhereOrNull((element) => element.name == packageName);
    });
  }

  void addPackage(PackageInfo info) {
    final packageInfos = selectController.items;
    if (packageInfos.where((p0) => p0.name == info.name).isNotEmpty) {
      Get.snackbar('已存在', '${info.name}已存在');
      return;
    }
    final baseName = basename(info.rootUri);
    final config = FixRuntimeConfiguration()
      ..name = baseName.split('-')[0]
      ..version = baseName.split('-')[1];
    packageInfos.add(FixSelectItem(config, config.name));
  }
}
