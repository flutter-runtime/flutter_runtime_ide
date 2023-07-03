import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
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

    selectController = FixSelectController(packageInfos);

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
    selectController.add(config);
  }

  PackageInfo? getPackageInfo(FixRuntimeConfiguration configuration) {
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    return packages.firstWhereOrNull((element) => element.packagePath
        .endsWith('${configuration.name}-${configuration.version}'));
  }

  Future<void> saveConfig() async {
    final items = selectController.items;
    final configs = AnalyzerPackageManager().fixRuntimeConfiguration;
    for (var item in items) {
      final index = configs.indexOf(item);
      if (index == -1) {
        configs.add(item);
      } else {
        configs[index] = item;
      }
    }
    AnalyzerPackageManager().fixRuntimeConfiguration = configs;
    showHUD();
    await AnalyzerPackageManager()
        .saveFixRuntimeConfiguration(AnalyzerPackageManager.defaultRuntimePath);
    hideHUD();
  }
}
