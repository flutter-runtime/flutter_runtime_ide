import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:path/path.dart';

class PackageConfig {
  late int configVersion;
  late String generated;
  late String generator;
  late String generatorVersion;
  late List<PackageInfo> packages;

  PackageConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    configVersion = jsonValue["configVersion"].intValue;
    generated = jsonValue["generated"].stringValue;
    generator = jsonValue["generator"].stringValue;
    generatorVersion = jsonValue["generatorVersion"].stringValue;
    packages = jsonValue["packages"]
        .listValue
        .map((e) => PackageInfo.fromJson(e))
        .toList();
  }
}

class PackageInfo {
  late String name;
  late String rootUri;
  late String packageUri;
  late String languageVersion;
  late String version;

  PackageInfo.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    rootUri = jsonValue["rootUri"].stringValue;
    packageUri = jsonValue["packageUri"].stringValue;
    languageVersion = jsonValue["languageVersion"].stringValue;
  }

  Future<void> initVersion([String? setVersion]) async {
    if (setVersion != null) {
      version = setVersion;
      return;
    }
    final names = basename(packagePath).split('-');
    if (names.length == 2) {
      version = names[1];
    } else {
      final versionCode = await this.versionCode();
      version = versionCode ?? md5Version;
    }
  }

  // 获取本地的路径 去掉 file://
  String get packagePath => rootUri.replaceFirst("file://", "");
  // 获取根据库在本地的路径经过md5加密获取的版本号
  String get md5Version => md5(packagePath);

  // 获取源代码所在的文件目录
  String get libPath => join(packagePath, packageUri);
  // 获取缓存在本地的文件夹名称
  String get cacheName => '$name-$version';

  String get runtimeName {
    if (name == 'flutter') {
      return '${name}_$version';
    } else {
      return '${name}_runtime';
    }
  }

  /// 根据引入的路径获取相对路径
  String relativePath(String sourcePath) {
    return sourcePath.split('package:$name/').last;
  }

  String relativePathFromFullPath(String fullPath) {
    return fullPath.split(libPath).last;
  }

  Future<String?> versionCode() async {
    final sdkNames = [
      'flutter',
      'sky_engin',
      'flutter_driver',
      'flutter_goldens',
      'flutter_goldens_client',
      'flutter_localizations',
      'flutter_test',
      'flutter_tools',
      'flutter_web_plugins',
      'fuchsia_remote_debug_protocol',
      'integration_test',
    ];
    if (sdkNames.contains(name)) {
      final paths = split(packagePath);
      paths.removeRange(paths.length - 2, paths.length - 1);
      final root = joinAll(paths);
      final versionPath = join(root, 'version');
      return loadVersionFromFile(File(versionPath));
    } else {
      final versionPath = join(packagePath, 'version');
      return loadVersionFromFile(File(versionPath));
    }
  }

  Future<String?> loadVersionFromFile(File file) async {
    if (!await file.exists()) return null;
    return file.readAsString();
  }
}

class PackageDependency {
  late String root;
  late List<String> executables;
  late List<PackageDependencyInfo> packages;
  late List<PackageDependencySDK> sdks;

  PackageDependency.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    root = jsonValue["root"].stringValue;
    executables = jsonValue["executables"]
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
    packages = jsonValue["packages"]
        .listValue
        .map((e) => PackageDependencyInfo.fromJson(e))
        .toList();
    sdks = jsonValue["sdks"]
        .listValue
        .map((e) => PackageDependencySDK.fromJson(e))
        .toList();
  }
}

class PackageDependencyInfo {
  late String name;
  late String version;
  late String kind;
  late String source;
  late List<String> dependencies;
  PackageDependencyInfo.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    version = jsonValue["version"].stringValue;
    kind = jsonValue["kind"].stringValue;
    source = jsonValue["source"].stringValue;
    dependencies = jsonValue["dependencies"]
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
  }
}

class PackageDependencySDK {
  late String name;
  late String version;

  PackageDependencySDK.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    version = jsonValue["version"].stringValue;
  }
}
