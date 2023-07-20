import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_parameter_data.dart';

class MustacheMethodData {
  final String callMethodName;
  final String methodName;
  final List<MustacheParametersData> parameters;
  final String? customCallCode;
  final bool isCustomCall;
  final bool isStatic;

  MustacheMethodData({
    required this.callMethodName,
    required this.methodName,
    required this.parameters,
    this.customCallCode,
    required this.isCustomCall,
    required this.isStatic,
  });

  Map<String, dynamic> toJson() {
    return {
      'callMethodName': callMethodName,
      'methodName': methodName,
      'parameters': parameters.map((e) => e.toJson()).toList(),
      'customCallCode': customCallCode,
      'isCustomCall': isCustomCall,
      'isStatic': isStatic
    };
  }
}
