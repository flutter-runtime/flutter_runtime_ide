import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:get/get.dart';

import '../../../data/package_config.dart';

class FixConfigController extends GetxController {
  TextEditingController packageNameController = TextEditingController();

  var packageInfos = <PackageInfo>[].obs;
  Rx<PackageInfo?> currentPackageInfo = Rx(null);

  FixConfigController() {
    packageInfos.value = AnalyzerPackageManager().packageConfig?.packages ?? [];
    if (packageInfos.isNotEmpty) {
      currentPackageInfo.value = packageInfos.first;
    }

    packageNameController.addListener(() {
      final packageName = packageNameController.text;
      currentPackageInfo.value = packageInfos
          .firstWhereOrNull((element) => element.name == packageName);
    });
  }
}
