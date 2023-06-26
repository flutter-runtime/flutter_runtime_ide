// ignore_for_file: implementation_imports

import 'package:analyzer/src/dart/analysis/results.dart';

class ImportAnalysis {
  final String? uriContent;
  final ResolvedLibraryResultImpl resultImpl;
  final List<String> showNames;
  final List<String> hideNames;
  final List<ImportAnalysis> imports;
  final String? asName;

  ImportAnalysis(
    this.uriContent,
    this.resultImpl, {
    this.showNames = const [],
    this.hideNames = const [],
    this.imports = const [],
    this.asName,
  });
}
