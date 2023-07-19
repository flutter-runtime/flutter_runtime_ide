import 'dart:io';

import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../../../../analyzer/configs/package_config.dart';

class FixConfigController extends GetxController {
  final PackageInfo packageInfo;

  var name = ''.obs;
  var version = ''.obs;

  FixSelectController<FixConfigItem> selectController = FixSelectController([]);

  FixConfigController(this.packageInfo) {
    name.value = packageInfo.name;
    version.value = packageInfo.version;
    readAllFile();
  }

  /// 读取当前依赖的所有源文件
  Future<void> readAllFile() async {
    final allSourceFiles =
        await AnalyzerPackageManager.readAllSourceFiles(packageInfo);
    final selectItems = allSourceFiles
        .whereType<File>()
        .map((e) => e.path)
        .where((element) => extension(element) == '.dart')
        .map((e) => FixConfigItem(e, filePath(e)))
        .toList();
    selectController.updateItems(selectItems);
  }

  /// 文件相对路径
  String filePath(String path) {
    return relative(path, from: packageInfo.libPath);
  }
}

class FixConfigItem with FixSelectItem {
  /// 全路径
  final String fullPath;

  /// 相对路径
  final String relativePath;
  FixConfigItem(this.fullPath, this.relativePath);

  @override
  String get name => relativePath;
}
