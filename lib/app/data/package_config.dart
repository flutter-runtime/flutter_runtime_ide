import 'package:darty_json_safe/darty_json_safe.dart';

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

  PackageInfo.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    rootUri = jsonValue["rootUri"].stringValue;
    packageUri = jsonValue["packageUri"].stringValue;
    languageVersion = jsonValue["languageVersion"].stringValue;
  }

  String get packagePath => rootUri.replaceFirst("file://", "");
}
