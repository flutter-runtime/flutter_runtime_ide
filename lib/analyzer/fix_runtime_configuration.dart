import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:get/get.dart';

class FixRuntimeConfiguration {
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
}

class FixConfig {
  late String path;
  List<FixClassConfig> classs = [];
  FixConfig();
  FixConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    path = jsonValue["path"].stringValue;
    classs = jsonValue["classs"]
        .listValue
        .map((e) => FixClassConfig.fromJson(e))
        .toList();
  }

  FixClassConfig? getClassConfig(String name) =>
      classs.firstWhereOrNull((element) => element.name == name);
}

class FixClassConfig {
  late String name;
  List<FixMethodConfig> methods = [];
  FixClassConfig();
  FixClassConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    methods = jsonValue["methods"]
        .listValue
        .map((e) => FixMethodConfig.fromJson(e))
        .toList();
  }

  FixMethodConfig? getMethodConfig(String name) =>
      methods.firstWhereOrNull((element) => element.name == name);
}

class FixMethodConfig {
  late String name;
  List<FixParameterConfig> parameters = [];
  FixMethodConfig();
  FixMethodConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    parameters = jsonValue["parameters"]
        .listValue
        .map((e) => FixParameterConfig.fromJson(e))
        .toList();
  }

  FixParameterConfig? getParameterConfig(String name) =>
      parameters.firstWhereOrNull((element) => element.name == name);
}

class FixParameterConfig {
  late String name;
  late String type;
  FixParameterConfig();
  FixParameterConfig.fromJson(Map<String, dynamic> json) {
    final jsonValue = JSON(json);
    name = jsonValue["name"].stringValue;
    type = jsonValue["type"].stringValue;
  }
}
