import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_class_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_import_data.dart';

class MustacheFileData {
  final String pubName;
  final List<MustacheClassData> classes;
  final List<MustacheImportData> paths;

  MustacheFileData({
    required this.pubName,
    required this.classes,
    required this.paths,
  });

  Map<String, dynamic> toJson() {
    return {
      'pubName': pubName,
      'classes': classes.map((e) => e.toJson()).toList(),
      'paths': paths.map((e) => e.toJson()).toList(),
    };
  }
}
