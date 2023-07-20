class MustacheParametersData {
  final String parameterName;
  final bool isNamed;
  final bool hasDefaultValue;
  final String? defaultValueCode;
  final String createInstanceCode;

  MustacheParametersData({
    required this.parameterName,
    required this.isNamed,
    required this.hasDefaultValue,
    required this.defaultValueCode,
    required this.createInstanceCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "parameterName": parameterName,
      "isNamed": isNamed,
      "hasDefaultValue": hasDefaultValue,
      "defaultValueCode": defaultValueCode,
      "createInstanceCode": createInstanceCode,
    };
  }
}
