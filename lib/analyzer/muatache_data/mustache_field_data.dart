class MustacheFieldData {
  final String fieldName;
  final String fieldValue;
  final bool isStatic;
  MustacheFieldData({
    required this.fieldName,
    required this.fieldValue,
    required this.isStatic,
  });

  Map<String, dynamic> toJson() {
    return {
      "fieldName": fieldName,
      "fieldValue": fieldValue,
      "isStatic": isStatic
    };
  }
}
