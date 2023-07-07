import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
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

class PackageInfo extends FixSelectItem {
  @override
  late String name;
  late String rootUri;
  late String packageUri;
  late String languageVersion;

  PackageInfo.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    rootUri = jsonValue["rootUri"].stringValue;
    packageUri = jsonValue["packageUri"].stringValue;
    languageVersion = jsonValue["languageVersion"].stringValue;
  }

  // 获取本地的路径 去掉 file://
  String get packagePath => rootUri.replaceFirst("file://", "");
  // 获取根据库在本地的路径经过md5加密获取的版本号
  String get md5Version => md5(packagePath);
  // 获取当前库的版本
  // 如果依赖的路径存在版本号,则返回版本号
  // 如果依赖的路径不存在版本号,则返回md5加密的版本号
  String get version {
    final names = basename(packagePath).split('-');
    if (names.length == 2) return names[1];
    return md5Version;
  }

  // 获取源代码所在的文件目录
  String get libPath => join(packagePath, packageUri);
  // 获取缓存在本地的文件夹名称
  String get cacheName => '$name-$version';
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
