// 用于缓存分析的内容
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:path/path.dart';

import '../common/common_function.dart';

class AnalyzerPackageManager {
  static final AnalyzerPackageManager _instance = AnalyzerPackageManager._();
  AnalyzerPackageManager._();
  factory AnalyzerPackageManager() => _instance;

  final Map<String, SomeResolvedLibraryResult> _libraries = {};
  final Map<String, AnalysisContextCollection> _collections = {};

  Future<SomeResolvedLibraryResult?> getResolvedLibrary(
    String packagePath,
    String libraryPath,
  ) async {
    final key = _libraryPath(packagePath, libraryPath);
    if (_libraries.containsKey(key)) {
      return _libraries[key];
    }
    final collection = getAnalysisContextCollection(packagePath);
    final result = await collection
        .contextFor(libraryPath)
        .currentSession
        .getResolvedLibrary(libraryPath);
    _libraries[key] = result;
    return result;
  }

  String _libraryPath(String packagePath, String libraryPath) {
    return md5("$packagePath:$libraryPath");
  }

  AnalysisContextCollection getAnalysisContextCollection(String packagePath) {
    AnalysisContextCollection? collection = _collections[packagePath];
    if (collection != null) {
      return collection;
    }
    AnalysisContextCollection contextCollection = AnalysisContextCollection(
      sdkPath: getDartPath(),
      includedPaths: [join(packagePath, "lib")],
    );
    _collections[packagePath] = contextCollection;
    return contextCollection;
  }
}
