import 'dart:convert';
import 'dart:io';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:process_run/process_run.dart';

class HomeController extends GetxController {
  // 当前操作的工程路径
  var progectPath = "".obs;

  /// 当前工程的第三方库的配置
  var packageConfig = Rx<PackageConfig?>(null);

  HomeController() {
    progectPath.value = Get.arguments as String;
    readPackageConfig();
  }

  // 读取当前工程的第三方库的配置
  FutureOr<void> readPackageConfig() async {
    String packageConfigPath =
        join(progectPath.value, ".dart_tool", "package_config.json");
    // 判断文件是否存在
    if (!await File(packageConfigPath).exists()) {
      Get.snackbar("错误!", "请先执行 flutter pub get");
      return;
    }

    // 读取文件内容
    String content = await File(packageConfigPath).readAsString();
    packageConfig.value = PackageConfig.fromJson(jsonDecode(content));
  }

  // 分析第三方库代码
  // [packagePath] 第三方库的路径
  FutureOr<void> analyzerPackageCode(String packagePath) async {
    await ConverRuntimePackage.fromPath(packagePath.replaceAll("file://", ""),
            "${platformEnvironment["PWD"]}/.runtime")
        .conver();
  }
}
