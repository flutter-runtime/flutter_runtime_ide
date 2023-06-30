import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../../analyzer/analyzer_package_manager.dart';

class FixFileController extends GetxController {
  final FixRuntimeConfiguration configuration;
  late FixSelectController<FixConfig> selectController;

  FixFileController(this.configuration) {
    selectController = FixSelectController(configuration.fixs.map((e) {
      return FixSelectItem(e, e.path);
    }).toList());
  }

  PackageInfo? get packageInfo {
    final packages = AnalyzerPackageManager().packageConfig?.packages ?? [];
    final result = packages.firstWhereOrNull((element) {
      return basename(element.rootUri) ==
          '${configuration.name}-${configuration.version}';
    });
    return result;
  }

  void addConfig(String path) {
    final config = FixConfig()..path = path;
    configuration.fixs.add(config);

    selectController.updateItems(configuration.fixs.map((e) {
      return FixSelectItem(e, e.path);
    }).toList());
  }
}
