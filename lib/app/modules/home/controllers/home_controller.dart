import 'dart:convert';
import 'dart:io';
import 'package:analyze_cache/analyze_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/file_runtime_generate.dart';
import 'package:flutter_runtime_ide/analyzer/generate_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache_manager.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:process_run/process_run.dart';

class HomeController extends GetxController {
  // 当前操作的工程路径
  var progectPath = "".obs;

  /// 当前工程的第三方库的配置
  var packageConfig = Rx<PackageConfig?>(null);

  // 用来过滤搜索
  TextEditingController searchController = TextEditingController();
  // 进行展示的包列表
  var displayPackages = <PackageInfo>[].obs;

  late PackageDependency dependency;

  HomeController() {
    progectPath.value = Get.arguments as String;
    Future.delayed(Duration.zero).then((value) async {
      await readPackageConfig();
    });
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
    showHUD();
    try {
      // 获取依赖详细配置
      final flutter = await which("flutter");
      List<ProcessResult> results =
          await Shell().run('''$flutter pub deps --json''');
      final result = results[0];

      String depsContent = result.stdout;
      final startIndex = depsContent.indexOf('{');
      depsContent = depsContent.substring(startIndex);
      final depsJson = json.decode(depsContent);
      dependency = PackageDependency.fromJson(depsJson);

      // 读取文件内容
      String content = await File(packageConfigPath).readAsString();
      packageConfig.value = PackageConfig.fromJson(jsonDecode(content));
      AnalyzerPackageManager().packageConfig = packageConfig.value;

      /// 讲依赖当前库路径修为为绝对路径
      for (var info in packageConfig.value!.packages) {
        if (info.rootUri == '../') {
          final userPath = platformEnvironment['HOME']!;
          info.rootUri = '$userPath${progectPath.value.split(userPath).last}';
        }
      }

      search();
      hideHUD();
    } catch (e) {
      hideHUD();
      if (e is ShellException) {
        Get.snackbar("错误!", e.result?.stderr);
      } else {
        Get.snackbar("错误!", e.toString());
      }
    }
  }

  // 分析第三方库代码
  // [packagePath] 第三方库的路径
  FutureOr<void> analyzerPackageCode(
    String packageName, [
    bool showProgress = true,
  ]) async {
    final config = packageConfig.value;
    if (config == null) return;
    ConverRuntimePackage package = ConverRuntimePackage(
      join(AnalyzerPackageManager.defaultRuntimePath, 'runtime'),
      config,
      dependency,
    );
    try {
      await package.conver(packageName, showProgress);
    } catch (e) {
      if (e is Error) {
        logger.e(e.stackTrace.toString());
      } else {
        logger.e(e.toString());
      }
    }
  }

  Future<void> analyzerAllPackageCode() async {
    showProgressHud();
    final infos =
        AnalyzerPackageManager.getAllowGeneratedPackages(packageConfig.value!);
    int index = 0;
    int count = infos.length;
    double progress = 1.0 / count;
    for (var info in infos) {
      index += 1;
      final generateRuntime = GenerateRuntimePackage(
        info,
        packageConfig.value!,
        dependency,
        allowInitProject: false,
        progress: (percent) {
          updateProgressHud(
            progress: progress * (index - 1) + progress * percent,
          );
        },
        analyzeProgress: (progress) => updateProgressHudText(progress),
      );
      await generateRuntime.generate();
    }
    updateProgressHud(progress: 1.0);
    Get.snackbar('成功!', '生成全部运行库完毕!');
  }

  search() {
    if (searchController.text.isEmpty) {
      displayPackages.value = packageConfig.value!.packages;
    } else {
      displayPackages.value = packageConfig.value!.packages
          .where((element) => element.name.contains(searchController.text))
          .toList();
    }
  }

  // 生成一个全局调用的运行库
  Future<void> generateGlobaleRuntimePackage() async {
    final packages =
        AnalyzerPackageManager.getAllowGeneratedPackages(packageConfig.value!);
    if (packages.isEmpty) return;

    /// 检测对应的运行时库是否已经生成
    for (var info in packages) {
      final runtimePath = AnalyzerPackageManager.getRuntimePath(info);
      if (!await Directory(runtimePath).exists()) {
        Get.snackbar('错误', '${info.name}的运行时库不存在');
        return;
      }
    }
    showHUD();

    const pubName = 'flutter_runtime_center';

    final data = {
      'pubName': pubName,
      'dependencies': packages.map((e) {
        return {
          'name': e.runtimeName,
          'path': AnalyzerPackageManager.getRuntimePath(e)
        };
      }).toList(),
    };

    const relativePath = '$pubName.dart';

    final fileData = {
      'imports': packages
          .map((e) => {
                'uriContent': 'package:${e.runtimeName}/${e.runtimeName}.dart',
              })
          .toList()
    };

    /// 生成运行时入口文件
    final runtimeGenerate = FileRuntimeGenerate(
      fileCache: AnalyzerFileCache(fileData, fileData),
      globalClassName: AnalyzerPackageManager.md5ClassName(relativePath),
      pubName: 'flutter_runtime_center',
      runtimeClassNames: packages.map((e) {
        return AnalyzerPackageManager.md5ClassName('${e.runtimeName}.dart');
      }).toList(),
    );

    final root = join(progectPath.value, '.runtime');

    final generateCode = await runtimeGenerate.generateCode();
    final file = File(join(root, 'lib', relativePath));
    await file.writeString(generateCode);

    final yamlContent =
        MustacheManager().render(globaleRuntimePackageMustache, data);
    final runtimePath = join(root, 'pubspec.yaml');
    await File(runtimePath).writeString(yamlContent);
    final flutter = await which("flutter");
    final dart = await which("dart");
    await Shell(workingDirectory: root).run('''
$flutter pub get
$dart format ./
''');
    hideHUD();
  }
}
