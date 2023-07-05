import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';

class FixRuntimeConfiguration extends FixSelectItem {
  @override
  late String name;
  late String version;
  List<FixConfig> fixs = [];

  FixRuntimeConfiguration();

  FixRuntimeConfiguration.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    version = jsonValue["version"].stringValue;
    fixs =
        jsonValue["fixs"].listValue.map((e) => FixConfig.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "version": version,
      "fixs": fixs.map((e) => e.toJson()).toList(),
    };
  }

  String get baseName {
    if (version.isEmpty) return name;
    return '$name-$version';
  }
}

class FixConfig extends FixSelectItem {
  late String path;
  List<FixClassConfig> classs = [];
  List<FixExtensionConfig> extensions = [];
  List<FixImportConfig> imports = [];
  List<FixMethodConfig> methods = [];

  @override
  String get name => path;

  FixConfig();
  FixConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    path = jsonValue["path"].stringValue;
    classs = jsonValue["classs"]
        .listValue
        .map((e) => FixClassConfig.fromJson(e))
        .toList();
    extensions = jsonValue["extensions"]
        .listValue
        .map((e) => FixExtensionConfig.fromJson(e))
        .toList();
    imports = jsonValue["imports"]
        .listValue
        .map((e) => FixImportConfig.fromJson(e))
        .toList();
    methods = jsonValue["methods"]
        .listValue
        .map((e) => FixMethodConfig.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "classs": classs.map((e) => e.toJson()).toList(),
      "extensions": extensions.map((e) => e.toJson()).toList(),
      "imports": imports.map((e) => e.toJson()).toList(),
      "methods": methods.map((e) => e.toJson()).toList(),
    };
  }

  FixClassConfig? getClassConfig(String name) {
    return classs.firstWhereOrNull((element) => element.name == name);
  }

  FixExtensionConfig? getExtensionConfig(String name) {
    return extensions.firstWhereOrNull((element) => element.name == name);
  }

  FixImportConfig? getImportConfig(int index) {
    return imports.firstWhereOrNull((element) => element.index == index);
  }

  FixMethodConfig? getMethodConfig(String name) {
    return methods.firstWhereOrNull((element) => element.name == name);
  }
}

class FixClassConfig extends FixSelectItem {
  @override
  late String name;

  bool isEnable = true;

  List<FixMethodConfig> methods = [];
  List<FixMethodConfig> constructors = [];
  FixClassConfig();
  FixClassConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    methods = jsonValue["methods"]
        .listValue
        .map((e) => FixMethodConfig.fromJson(e))
        .toList();
    constructors = jsonValue["constructors"]
        .listValue
        .map((e) => FixMethodConfig.fromJson(e))
        .toList();
    isEnable = jsonValue["isEnable"].bool ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "methods": methods.map((e) => e.toJson()).toList(),
      "constructors": constructors.map((e) => e.toJson()).toList(),
      "isEnable": isEnable,
    };
  }

  FixMethodConfig? getMethodConfig(String name) =>
      methods.firstWhereOrNull((element) => element.name == name);

  FixMethodConfig? getConstructorConfig(String name) {
    return constructors.firstWhereOrNull((element) => element.name == name);
  }
}

class FixMethodConfig extends FixSelectItem {
  @override
  late String name;
  bool isEnable = true;
  List<FixParameterConfig> parameters = [];
  FixMethodConfig();
  FixMethodConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    parameters = jsonValue["parameters"]
        .listValue
        .map((e) => FixParameterConfig.fromJson(e))
        .toList();
    isEnable = jsonValue["isEnable"].bool ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "parameters": parameters.map((e) => e.toJson()).toList(),
      "isEnable": isEnable,
    };
  }

  FixParameterConfig? getParameterConfig(String name) =>
      parameters.firstWhereOrNull((element) => element.name == name);
}

class FixParameterConfig extends FixSelectItem {
  @override
  late String name;
  late String type;
  FixParameterConfig();
  FixParameterConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    type = jsonValue["type"].stringValue;
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
    };
  }
}

class FixExtensionConfig extends FixSelectItem {
  @override
  late String name;
  bool isEnable = true;

  List<FixMethodConfig> methods = [];

  FixExtensionConfig();
  FixExtensionConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    isEnable = jsonValue["isEnable"].bool ?? true;
    methods = jsonValue["methods"]
        .listValue
        .map((e) => FixMethodConfig.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "isEnable": isEnable,
      "methods": methods.map((e) => e.toJson()).toList(),
    };
  }

  FixMethodConfig? getMethodConfig(String name) =>
      methods.firstWhereOrNull((element) => element.name == name);
}

class FixImportConfig extends FixSelectItem {
  @override
  String get name => '$index $path';
  late String path;
  late int index;
  String? asName;
  List<String> showNames = [];
  List<String> hideNames = [];
  bool isEnable = true;
  FixImportConfig();
  FixImportConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    path = jsonValue["path"].stringValue;
    index = jsonValue["index"].intValue;
    asName = jsonValue["asName"].string;
    showNames = jsonValue["showNames"]
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
    hideNames = jsonValue["hideNames"]
        .listValue
        .map((e) => JSON(e).stringValue)
        .toList();
    isEnable = jsonValue["isEnable"].bool ?? true;
  }

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      'asName': asName,
      'showNames': showNames,
      'hideNames': hideNames,
      'index': index,
      "isEnable": isEnable,
    };
  }
}
