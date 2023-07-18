import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

import '../../../../analyzer/analyze_info.dart';

class AnalyzerInfoController extends GetxController {
  final PackageInfo packageInfo;
  final List<AnalyzeInfo> infos;
  AnalyzerInfoController(this.packageInfo, this.infos);

  /// 获取分析的文件路径列表
  List<String> get filePaths => infos.map((e) => e.filePath).toSet().toList();

  /// 通过路径查询当前路径的分析信息列表
  /// [filePath] 查询的路径
  List<AnalyzeInfo> getInfo(String filePath) =>
      infos.where((e) => e.filePath == filePath).toList();

  /// 通过 VSCode  打开对应的代码行
  Future<void> openFileLine(AnalyzeInfo info) async {
    final open = await which('open');
    final code = await which('code');
    final filePath = info.filePath.replaceFirst(' ', '');
    final cachePath = join(
      AnalyzerPackageManager.defaultRuntimePath,
      'runtime',
      packageInfo.cacheName,
    );
    final fullFilePath = join(cachePath, filePath);
    Shell().run(
      '''
$open $cachePath -a "Visual Studio Code.app"
$code -g $fullFilePath:${info.line}:${info.column}
''',
    );
  }
}
