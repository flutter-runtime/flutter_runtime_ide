// 用于缓存分析的内容
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

import '../common/common_function.dart';

class AnalyzerPackageManager {
  static final AnalyzerPackageManager _instance = AnalyzerPackageManager._();
  AnalyzerPackageManager._();
  factory AnalyzerPackageManager() => _instance;
  // 存储每个文件对应解析结果的缓存
  final Map<String, Map<String, SomeResolvedLibraryResult>> _libraries = {};
  // 存储每一个库对应分析的上下文
  final Map<String, AnalysisContextCollection> _collections = {};

  List<FixRuntimeConfiguration> fixRuntimeConfiguration = [];
  PackageConfig? packageConfig;

  // 根据库的路径和文件的路径获取分析结果
  // [packagePath] 库对应路径
  // [libraryPath] 文件对应路径
  Future<SomeResolvedLibraryResult> getResolvedLibrary(
    String packagePath,
    String libraryPath,
  ) async {
    Map<String, SomeResolvedLibraryResult> results = this.results(packagePath);
    late SomeResolvedLibraryResult result;
    if (results.containsKey(libraryPath)) {
      result = results[libraryPath]!;
    } else {
      final collection = _getAnalysisContextCollection(packagePath);
      result = await collection
          .contextFor(libraryPath)
          .currentSession
          .getResolvedLibrary(libraryPath);
      results[libraryPath] = result;
      _libraries[packagePath] = results;
    }
    return result;
  }

  AnalysisContextCollection _getAnalysisContextCollection(String packagePath) {
    AnalysisContextCollection? collection = _collections[packagePath];
    if (collection != null) {
      return collection;
    }
    AnalysisContextCollection contextCollection = AnalysisContextCollection(
      sdkPath: getDartPath(),
      includedPaths: [join(packagePath, "lib")],
    );
    _collections[packagePath] = contextCollection;
    return contextCollection;
  }

  Map<String, SomeResolvedLibraryResult> results(String packagePath) {
    return _libraries[packagePath] ?? {};
  }

  Future<void> loadFixRuntimeConfiguration(String root) async {
    final loadPath = join(root, '.fix_runtime.json');
    if (!await File(loadPath).exists()) {
      return;
    }
    final jsonText = await File(loadPath).readAsString();
    fixRuntimeConfiguration = JSON(jsonDecode(jsonText)).listValue.map((e) {
      return FixRuntimeConfiguration.fromJson(e);
    }).toList();
  }

  Future<void> saveFixRuntimeConfiguration(String root) async {
    final jsonValue = fixRuntimeConfiguration.map((e) => e.toJson()).toList();
    final jsonText = const JsonEncoder.withIndent('  ').convert(jsonValue);
    final savePath = join(root, '.fix_runtime.json');
    await File(savePath).writeAsString(jsonText);
  }

  FixRuntimeConfiguration? getFixRuntimeConfiguration(PackageInfo info) {
    final path = basename(info.rootUri);
    final configurations =
        fixRuntimeConfiguration.where((element) => element.baseName == path);
    if (configurations.isEmpty) return null;
    return configurations.first;
  }

  List<String> getPackageLibraryPaths(String packagePath) {
    return Unwrap(_libraries[packagePath]).map((e) {
          return e.keys.toList();
        }).value ??
        [];
  }

  SomeResolvedLibraryResult? getResult(String fullPath) {
    for (var list in _libraries.values) {
      if (list.containsKey(fullPath)) {
        return list[fullPath]!;
      }
    }
    return null;
  }

  static String get defaultRuntimePath {
    return join(
      platformEnvironment['HOME']!,
      '.runtime',
    );
  }
}
