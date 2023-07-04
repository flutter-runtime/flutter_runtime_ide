import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../../analyzer/analyzer_package_manager.dart';
import '../../../data/package_config.dart';

class FixConfigController extends GetxController {
  final FixRuntimeConfiguration configuration;

  var name = ''.obs;
  var version = ''.obs;

  late FixSelectController<FixConfig> selectController;

  FixConfigController(this.configuration) {
    selectController = FixSelectController(configuration.fixs);
    name.value = configuration.name;
    version.value = configuration.version;
  }

  PackageInfo? get packageInfo {
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    final result = packages.firstWhereOrNull((element) {
      return basename(element.rootUri) ==
          '${configuration.name}-${configuration.version}';
    });
    return result;
  }

  void addConfig(String name) {
    final config = FixConfig()..path = name;
    selectController.add(config);
    configuration.fixs = selectController.items;
  }

  String? getFullPath(FixConfig config) {
    final packagePath = packageInfo?.packagePath;
    if (packagePath == null) return null;
    final paths = AnalyzerPackageManager().getPackageLibraryPaths(packagePath);
    return paths.firstWhereOrNull((element) {
      return element.endsWith(config.path);
    });
  }
}
