import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../../analyzer/package_config.dart';

class FixRuntimeConfigController extends GetxController {
  TextEditingController packageNameController = TextEditingController();

  // var packageInfos = <FixRuntimeConfiguration>[].obs;
  Rx<PackageInfo?> currentPackageInfo = Rx(null);

  late FixSelectController<FixRuntimeConfiguration> selectController;

  List<FixRuntimeConfiguration> _otherConfigurations = [];

  FixRuntimeConfigController() {
    final configs = AnalyzerPackageManager().fixRuntimeConfiguration;
    final packageInfos = configs
        .map((e) {
          final packages =
              AnalyzerPackageManager().packageConfig?.packages ?? [];
          final result = packages.firstWhereOrNull((element) {
            return '${e.name}${e.version.isEmpty ? '' : "-${e.version}"}' ==
                basename(element.rootUri);
          });
          if (result == null) {
            _otherConfigurations.add(e);
          }
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
      ..version = JSON(baseName.split('-'))[1].string ?? '';
    selectController.add(config);
  }

  PackageInfo? getPackageInfo(FixRuntimeConfiguration configuration) {
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    return packages.firstWhereOrNull((element) => element.packagePath.endsWith(
        '${configuration.name}${configuration.version.isEmpty ? '' : '-${configuration.version}'}'));
  }

  Future<void> saveConfig() async {
    final items = selectController.items;
    // 添加其他配置
    items.addAll(_otherConfigurations);
    AnalyzerPackageManager().fixRuntimeConfiguration = items;
    showHUD();
    await AnalyzerPackageManager()
        .saveFixRuntimeConfiguration(AnalyzerPackageManager.defaultRuntimePath);
    hideHUD();
  }
}
