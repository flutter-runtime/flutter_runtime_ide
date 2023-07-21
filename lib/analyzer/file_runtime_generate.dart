// ignore_for_file: implementation_imports

import 'package:analyze_cache/analyze_cache.dart' hide StringPrivate, ListFirst;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:darty_json_safe/darty_json_safe.dart';

import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_class_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_constructor_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_field_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_file_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_import_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_method_data.dart';
import 'package:flutter_runtime_ide/analyzer/muatache_data/mustache_parameter_data.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache.dart';
import 'package:flutter_runtime_ide/analyzer/mustache/mustache_manager.dart';
import 'package:analyzer/src/dart/analysis/results.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:process_run/process_run.dart';

class FileRuntimeGenerate {
  final String globalClassName;
  final String pubName;
  final AnalyzerFileCache fileCache;
  final List<String>? runtimeClassNames;

  FileRuntimeGenerate({
    required this.globalClassName,
    required this.pubName,
    required this.fileCache,
    this.runtimeClassNames,
  });

  Future<String> generateCode() async {
    // await addImportHideNames();
    final classes = fileCache.classs
        .where((e) => e.isEnable && !e.name.isPrivate)
        .map((e) => toClassData(e))
        .toList();

    classes.addAll(fileCache.extensions
        .where((element) {
          return element.isEnable &&
              !(element.name.isPrivate) &&
              element.name.isNotEmpty;
        })
        .map((e) => toExtensionData(e))
        .toList());
    classes.addAll(fileCache.enums
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toEnumData(e))
        .toList());
    classes.addAll(fileCache.mixins
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMixinData(e))
        .toList());

    /// 获取所有已经被注册的运行时类名
    final runtimeClassNames =
        this.runtimeClassNames ?? classes.map((e) => e.className).toList();
    classes.add(toGlobalClass(runtimeClassNames));

    final data = {
      "pubName": pubName,
      "classes": classes,
    };

    final pathDatas = fileCache.imports.map((e) {
      final hideNames = e.hideNamesFromFileCache(fileCache);
      return MustacheImportData(
        uriContent: e.uriContent,
        asName: e.asName,
        hasAsName: e.asName != null,
        hasShowNames: e.shownNames.isNotEmpty,
        hasHideNames: hideNames.isNotEmpty,
        showContent: e.shownNames.join(","),
        hideContent: hideNames.join(','),
      );
    }).toList();
    data['paths'] = pathDatas;
    final fileData = MustacheFileData(
      pubName: pubName,
      classes: classes,
      paths: pathDatas,
    );
    return MustacheManager().render(fileMustache, fileData.toJson());
  }

  MustacheClassData toGlobalClass(List<String> runtimeNames) {
    final getFields = fileCache.topLevelVariables
        .where((e) => e.isGetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    // getFields.addAll(_typeAliases.map((e) => toTypeAliasData(e)).toList());

    final setFields = fileCache.topLevelVariables
        .where((e) => e.isSetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();

    final methods = fileCache.functions
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toFunctionData(e))
        .toList();
    return MustacheClassData(
      className: globalClassName,
      getFields: getFields,
      setFields: setFields,
      methods: methods,
      constructors: [],
      isAbstract: false,
      runtimeTypeString: 'dynamic',
      instanceType: 'dynamic',
      prefix: '',
      staticPrefix: '',
      isGlobal: true,
      runtimeNames: runtimeNames,
    );
  }

  MustacheClassData toClassData(AnalyzerClassCache element) {
    // bool isStructAndUnionSubClass =
    //     ['Struct', 'Union'].contains(element.supertype?.name);

    final getFields = element.fields
        .where((e) => e.isGetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((e) => e.isSetter && e.isEnable && !e.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toConstructorData(e))
        .toList();
    return MustacheClassData(
      className: '\$${element.name}\$',
      getFields: getFields,
      setFields: setFields,
      methods: methods,
      constructors: constructors,
      isAbstract: element.isAbstract,
      runtimeTypeString: element.name,
      instanceType: '${element.name}?',
      prefix: 'runtime.',
      staticPrefix: '${element.name}.',
      isGlobal: false,
    );
  }

  MustacheClassData toEnumData(AnalyzerEnumCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    // final constructors = element.constructors
    //     .where((element) => !element.name.isPrivate)
    //     .map((e) => toConstructorData(e))
    //     .toList();
    return MustacheClassData(
      className: '\$${element.name}\$',
      getFields: getFields,
      setFields: setFields,
      methods: methods,
      constructors: [],
      isAbstract: false,
      runtimeTypeString: element.name,
      instanceType: "${element.name}?",
      prefix: 'runtime.',
      staticPrefix: '${element.name}.',
      isGlobal: false,
    );
  }

  MustacheClassData toMixinData(AnalyzerMixinCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    final constructors = element.constructors
        .where((element) => !element.name.isPrivate && !element.name.isPrivate)
        .map((e) => toConstructorData(e))
        .toList();
    return MustacheClassData(
      className: '\$${element.name}\$',
      getFields: getFields,
      setFields: setFields,
      methods: methods,
      constructors: constructors,
      isAbstract: false,
      runtimeTypeString: element.name,
      instanceType: '${element.name}?',
      prefix: 'runtime.',
      staticPrefix: '${element.name}.',
      isGlobal: false,
    );
  }

  MustacheMethodData toFunctionData(AnalyzerMethodCache element) {
    String? customCallCode;
    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    }
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return MustacheMethodData(
      callMethodName: element.name.replaceAll('\$', '\\\$'),
      methodName: element.name,
      parameters: parameters,
      customCallCode: customCallCode,
      isCustomCall: customCallCode != null,
      isStatic: element.isStatic,
    );
  }

  MustacheFieldData toPropertyAccessorData(
      AnalyzerPropertyAccessorCache element) {
    String fieldName = element.name;
    if (fieldName.endsWith("=")) {
      fieldName = fieldName.substring(0, fieldName.length - 1);
    }
    return MustacheFieldData(
      fieldName: fieldName.replaceAll("\$", "\\\$"),
      fieldValue: fieldName,
      isStatic: element.isStatic,
    );
  }

  MustacheClassData toExtensionData(AnalyzerExtensionCache element) {
    final getFields = element.fields
        .where((element) =>
            element.isEnable && element.isGetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final setFields = element.fields
        .where((element) =>
            element.isEnable && element.isSetter && !element.name.isPrivate)
        .map((e) => toPropertyAccessorData(e))
        .toList();
    final methods = element.methods
        .where((element) => element.isEnable && !element.name.isPrivate)
        .map((e) => toMethodData(e))
        .toList();
    // final runtimeType = runtimeNameWithType(element.extendedType);
    // final runtimeType = Unwrap(element.name)
    //     .map((e) => getExtensionDeclaration(e))
    //     .map((e) => getExtensionOnType(e))
    //     .value;

    String? instanceType = Unwrap(element.extensionName).map((e) {
      if (e.endsWith("?")) return e;
      return "$e?";
    }).value;
    return MustacheClassData(
      className: '\$${element.name}\$',
      getFields: getFields,
      setFields: setFields,
      methods: methods,
      constructors: [],
      isAbstract: false,
      runtimeTypeString: element.extensionName,
      instanceType: instanceType,
      prefix: '${element.name}(runtime).',
      staticPrefix: '${element.name}.',
      isGlobal: false,
    );
  }

  MustacheMethodData toMethodData(AnalyzerMethodCache element) {
    String? customCallCode;
    // 支持的计算公式
    final supportOperations = [
      '<',
      '<=',
      '>',
      '>=',
      '+',
      '&',
      '|',
      '*',
      '/',
      '-',
      '^',
      '~/',
      '%',
      '<<',
      '>>',
      '>>>'
    ];

    if (element.name == '[]=' && element.parameters.length == 2) {
      customCallCode =
          '''runtime[args['${element.parameters[0].name}']] = args['${element.parameters[1].name}']''';
    } else if (element.name == '==' && element.parameters.length == 1) {
      customCallCode = '''runtime == args['${element.parameters[0].name}']''';
    } else if (element.name == '[]') {
      customCallCode = '''runtime[args['${element.parameters[0].name}']]''';
    } else if (supportOperations.contains(element.name)) {
      customCallCode =
          '''runtime ${element.name} args['${element.parameters[0].name}']''';
    } else if (element.name.startsWith('unary')) {
      final operation = element.name.substring(5);
      customCallCode = '''${operation}runtime''';
    } else if (element.name == '~') {
      customCallCode = '${element.name}runtime';
    }
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return MustacheMethodData(
      callMethodName: element.name.replaceAll('\$', '\\\$'),
      methodName: element.name,
      parameters: parameters,
      customCallCode: customCallCode,
      isCustomCall: customCallCode != null,
      isStatic: element.isStatic,
    );
  }

  MustacheConstructorData toConstructorData(AnalyzerMethodCache element) {
    final parameters =
        element.parameters.map((e) => toParametersData(e)).toList();
    return MustacheConstructorData(
      constructorName: element.name,
      parameters: parameters,
      isName: element.name.isNotEmpty,
    );
  }

  MustacheParametersData toParametersData(
      AnalyzerPropertyAccessorCache element) {
    String readArgCode = '''args['${element.name}']''';
    Unwrap(element.asName).map((e) {
      readArgCode += 'as $e';
    });
    final defaultValueCode = defaultValueCodeFromParameter(element);
    return MustacheParametersData(
      parameterName: element.name,
      isNamed: element.isNamed,
      hasDefaultValue: element.hasDefaultValue,
      defaultValueCode: defaultValueCode,
      createInstanceCode: readArgCode,
      // 'isDartCoreObject': element.type.isDartCoreObject,
    );
  }

  String? defaultValueCodeFromParameter(
      AnalyzerPropertyAccessorCache elementCache) {
    String? defaultValueCode = elementCache.defaultValueCode;
    AnalyzerCache? parent = elementCache.parent;
    while (parent != null) {
      if (parent is AnalyzerClassCache) {
        AnalyzerClassCache classCache = parent;
        Unwrap(defaultValueCode)
            .map((e) => classCache.defaultValueCodeFromClass(e))
            .map((e) => defaultValueCode = e);
      } else if (parent is AnalyzerFileCache) {
        AnalyzerFileCache fileCache = parent;
        Unwrap(defaultValueCode)
            .map((e) => fileCache.defaultValueCodeFromTopLevelVariable(e))
            .map((e) => defaultValueCode = e);
      }
      parent = parent.parent;
    }
    return defaultValueCode;
  }
}

extension StringPrivate on String {
  bool get isPrivate => startsWith("_");
}
