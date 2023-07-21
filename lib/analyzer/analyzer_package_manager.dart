// 用于缓存分析的内容
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyze_cache/analyze_cache.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_file_cache.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/conver_runtime_package.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
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

  /// 存储分析缓存 用于运行提速
  final Map<String, AnalyzerFileCache> _fileCacheMap = {};

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

  /// 获取分析文件的缓存信息
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析的文件路径
  /// [useCache] 是否使用本地的分析缓存 默认为  true
  Future<AnalyzerFileCache?> getAnalyzerFileCache(
    PackageInfo info,
    String filePath, [
    bool useCache = true,
  ]) async {
    if (useCache) {
      if (_fileCacheMap.containsKey(filePath)) {
        return _fileCacheMap[filePath];
      }
      final cache = await readFileCache(info, filePath);
      if (cache != null) {
        logger.i('[🟢使用缓存] $filePath');
        _fileCacheMap[filePath] = cache;
        return cache;
      }
    }
    final result = await getResolvedLibrary(info.packagePath, filePath);
    if (result is! ResolvedLibraryResult) {
      return null;
    }
    final cache = await readFileCache(info, filePath);
    final elementCache = AnalyzerLibraryElementCacheImpl(
      result,
      Unwrap(cache).map((e) => e.map).defaultValue({}),
    );
    await saveFileCache(info, elementCache, filePath);
    _fileCacheMap[filePath] = elementCache;
    return cache;
  }

  /// 获取指定分析库的分析缓存文件配置路径
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析文件的路径
  String getAnalyzerCacheFilePath(PackageInfo info, String filePath) {
    final relativePath = relative(filePath, from: info.libPath);
    return join(
      defaultRuntimePath,
      'config',
      'analyzer_cache',
      info.cacheName,
      '$relativePath.json',
    );
  }

  /// 根据包信息和文件路径获取对应分析缓存信息
  /// [info] 当前分析文件对应库信息
  /// [filePath] 分析文件的路径
  Future<AnalyzerFileCache?> readFileCache(
    PackageInfo info,
    String filePath,
  ) async {
    /// 获取分析缓存文件的路径
    final path = getAnalyzerCacheFilePath(info, filePath);
    if (!await File(path).exists()) {
      return null;
    }

    /// 读取缓存文件内容
    final jsonText = await File(path).readAsString();
    final data = jsonDecode(jsonText);
    return AnalyzerFileCache(data, data);
  }

  /// 将分析结果写入缓存
  /// [info] 当前分析文件对应库信息
  /// [cache] 分析结果缓存
  /// [filePath] 分析文件的路径
  Future<void> saveFileCache(
    PackageInfo info,
    AnalyzerFileCache cache,
    String filePath,
  ) async {
    final jsonValue = cache.toJson();
    final jsonText = const JsonEncoder.withIndent('  ').convert(jsonValue);
    final path = getAnalyzerCacheFilePath(info, filePath);
    await File(path).writeString(jsonText);
  }

  /// 根据依赖的全路径获取依赖库信息
  /// [fullPath] 全路径
  PackageInfo? getPackageInfoFromFullPath(String fullPath) {
    return packageConfig?.packages.firstWhereOrNull((element) {
      return fullPath.startsWith(element.libPath);
    });
  }

  /// 根据包名获取包信息
  /// [name] 包名
  PackageInfo? getPackageInfoFromName(String name) {
    return packageConfig?.packages.firstWhereOrNull((element) {
      return element.name == name;
    });
  }

  /// 根据包路径和文件路径获取分析内存缓存
  /// [packagePath] 包路径
  /// [libraryPath] 文件路径
  ResolvedLibraryResult? getResolvedLibraryCache(
    String packagePath,
    String libraryPath,
  ) {
    Map<String, SomeResolvedLibraryResult> results = this.results(packagePath);
    return results[libraryPath] as ResolvedLibraryResult?;
  }

  ResolvedLibraryResult? getResolvedLibraryFromUriContent(String uriContent) {
    String? packagePath;
    String? libraryPath;
    if (uriContent.startsWith("package:")) {
      final content = uriContent.replaceFirst("package:", "");
      final contentPaths = content.split('/');
      final packageName = contentPaths[0];
      contentPaths.removeAt(0);
      final info = AnalyzerPackageManager().getPackageInfoFromName(packageName);
      if (info == null) return null;
      packagePath = info.rootUri.replaceFirst("file://", "").split('lib')[0];
      libraryPath = join(packagePath, 'lib', contentPaths.join('/'));
    }
    if (packagePath == null || libraryPath == null) return null;
    return getResolvedLibraryCache(packagePath, libraryPath);
  }

  /// 根据依赖库的配置信息读取全部的代码文件路径
  /// [info] 当前分析文件对应库信息
  static Future<List<File>> readAllSourceFiles(PackageInfo info) async {
    final directory = Directory(info.libPath);
    if (!directory.existsSync()) {
      return [];
    }
    List<File> files = [];
    Completer<List<File>> completer = Completer();
    final stream = directory.list(recursive: true);
    stream.listen((event) {
      if (event is File && extension(event.path) == '.dart') {
        files.add(event);
      }
    }, onDone: () {
      completer.complete(files);
    }, onError: (e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  /// 根据依赖库的配置信息获取到对应运行时库的路径地址
  /// [info] 依赖库的配置信息
  static String getRuntimePath(PackageInfo info) {
    return join(defaultRuntimePath, 'runtime', info.cacheName);
  }

  /// 从依赖库配置获取允许生成的依赖库列表
  /// [config] 依赖库的配置信息
  static List<PackageInfo> getAllowGeneratedPackages(PackageConfig config) {
    return config.packages.where((element) {
      return !getNotAllowPackageNames.contains(element.name);
    }).toList();
  }

  /// 不允许生成的库的名称
  static List<String> get getNotAllowPackageNames => [
        'flutter_lints',
        'flutter_test',
        'lints',
      ];

  /// 根据相对于依赖库中相对路径获取加密的 md5 的类名
  /// [relativePath] 相对路径
  static String md5ClassName(String relativePath) {
    return "FR${md5(relativePath)}";
  }
}
