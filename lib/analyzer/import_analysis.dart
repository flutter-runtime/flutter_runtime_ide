// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/analysis/results.dart';

class ImportAnalysis {
  final String? uriContent;
  final List<String> showNames;
  final List<String> hideNames;
  final String? asName;

  ImportAnalysis(
    this.uriContent, {
    this.showNames = const [],
    this.hideNames = const [],
    this.asName,
  });
}
