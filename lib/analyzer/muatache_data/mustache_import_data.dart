class MustacheImportData {
  final String? uriContent;
  final String? asName;
  final bool hasAsName;
  final bool hasShowNames;
  final bool hasHideNames;
  final String showContent;
  final String hideContent;

  MustacheImportData({
    required this.uriContent,
    required this.asName,
    required this.hasAsName,
    required this.hasShowNames,
    required this.hasHideNames,
    required this.showContent,
    required this.hideContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'uriContent': uriContent,
      'asName': asName,
      'hasAsName': hasAsName,
      'hasShowNames': hasShowNames,
      'hasHideNames': hasHideNames,
      'showContent': showContent,
      'hideContent': hideContent,
    };
  }
}
