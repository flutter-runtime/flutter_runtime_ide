// ignore_for_file: implementation_imports
import 'package:analyzer/src/dart/resolver/scope.dart';

class ImportAnalysis {
  final String? uriContent;
  List<String> showNames;
  List<String> hideNames;
  String? asName;
  final Namespace? exportNamespace;

  ImportAnalysis(
    this.uriContent, {
    this.showNames = const [],
    this.hideNames = const [],
    this.asName,
    this.exportNamespace,
  });
}
