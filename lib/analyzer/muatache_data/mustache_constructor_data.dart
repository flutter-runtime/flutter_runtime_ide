import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_parameter_data.dart';

class MustacheConstructorData {
  final String constructorName;
  final List<MustacheParametersData> parameters;
  final bool isName;

  MustacheConstructorData({
    required this.constructorName,
    required this.parameters,
    required this.isName,
  });

  Map<String, dynamic> toJson() {
    return {
      "constructorName": constructorName,
      "parameters": parameters.map((e) => e.toJson()).toList(),
      "isName": isName,
    };
  }
}
