import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';

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

  String get packagePath => rootUri.replaceFirst("file://", "");
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
