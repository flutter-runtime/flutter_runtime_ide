const classMustache = '''
class \${{className}}\$ extends FlutterRuntime<{{className}}>{

\${{className}}\$(super.runtime);

{{>getFieldMustache}}

{{>setFieldMustache}}

{{>methodMustache}}

{{>constructorMustache}}
}
''';

const fileMustache = '''
// ignore_for_file: implementation_imports, unused_import
import 'dart:async';
import 'package:flutter_runtime/flutter_runtime.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
{{#paths}}
import '{{{sourcePath}}}';
{{/paths}}

{{#classes}}
{{>classMustache}}
{{/classes}}
''';

const getFieldMustache = '''
@override
dynamic getField(String fieldName) {
  {{#getFields}}
  {{#isStatic}}
  if (fieldName == "{{fieldName}}") return {{className}}.{{fieldName}};
  {{/isStatic}}
  {{^isStatic}}
  if (fieldName == "{{fieldName}}") return runtime.{{fieldName}};
  {{/isStatic}}
  {{/getFields}}
}
''';

const setFieldMustache = '''
@override
void setField(String fieldName, dynamic value) {
  {{#setFields}}
    {{#isStatic}}
      if (fieldName == "{{fieldName}}") {{className}}.{{fieldName}} = value;
    {{/isStatic}}
    {{^isStatic}}
      if (fieldName == "{{fieldName}}") runtime.{{fieldName}} = value;
    {{/isStatic}}
  {{/setFields}}
}
''';

const methodMustache = '''
@override
dynamic call(String methodName,[Map args = const {}]) {
  {{#methods}}
  {{>functionMustache}}
  {{/methods}}
}
''';

const constructorMustache = '''

{{className}}? createRuntimeInstance(String constructorName,[Map args = const {},]) {
  {{^isAbstract}}
    {{#constructors}}
      if (constructorName == "{{constructorName}}")
        return {{className}}{{#isName}}.{{constructorName}}{{/isName}}(
          {{#parameters}}
            {{#isNamed}}
              {{parameterName}}:{{>createInstanceMustache}}{{>defaultValueMustache}},
            {{/isNamed}}
            {{^isNamed}}
              {{>createInstanceMustache}}{{>defaultValueMustache}},
            {{/isNamed}}
          {{/parameters}}
        );
    {{/constructors}}
  {{/isAbstract}}
  return null;
} 
''';

const defaultValueMustache = '''
{{#hasDefaultValue}}
  ?? {{defaultValueCode}}
{{/hasDefaultValue}}
''';

const pubspecMustache = '''
name: {{pubName}}_runtime
environment:
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  flutter_runtime:
    path: {{{flutterRuntimePath}}}
  {{pubName}}:
    path: {{{pubPath}}}
  darty_json_safe: ^1.0.1
''';

const globalMustache = '''
// ignore_for_file: implementation_imports, unused_import
import 'package:flutter_runtime/flutter_runtime.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
{{#paths}}
import '{{{sourcePath}}}';
{{/paths}}

class \$GlobalRuntime\$ extends FlutterRuntime<dynamic> {
 \$GlobalRuntime\$(super.runtime);

  dynamic call(String methodName, [Map args = const {}]) {
    {{#functions}}
      if (methodName == '{{methodName}}') return {{methodName}}(
    {{#parameters}}
      {{#isNamed}}
        {{parameterName}}:{{>createInstanceMustache}}{{>defaultValueMustache}},
      {{/isNamed}}
      {{^isNamed}}
        {{>createInstanceMustache}}{{>defaultValueMustache}},
      {{/isNamed}}
    {{/parameters}}
    );
    {{/functions}}
  }

  @override
  getField(String fieldName) {
    {{#getFields}}
        if (fieldName == '{{fieldName}}') return {{fieldValue}};
    {{/getFields}}
  }
    
  @override
  void setField(String fieldName, value) {
    {{#setFields}}
      if (fieldName == "{{fieldName}}") {{fieldName}} = value;
    {{/setFields}}
  }

  dynamic getEnumValue(String enumName, String constructorName) {
    {{#enums}}
      if (enumName == "{{enumName}}"){
        {{#constructors}}
          if (constructorName == '{{constructorName}}') {
            return {{enumName}}.{{constructorName}};
          }
        {{/constructors}}
      }
    {{/enums}}
    return null;  
  }
} 
''';

const functionMustache = '''
{{#isCustomCall}}
  if (methodName == '{{methodName}}') return {{{customCallCode}}};
{{/isCustomCall}}
{{^isCustomCall}}
  if (methodName == '{{methodName}}') return runtime.{{methodName}}(
    {{#parameters}}
      {{#isNamed}}
        {{parameterName}}:{{>createInstanceMustache}}{{>defaultValueMustache}},
      {{/isNamed}}
      {{^isNamed}}
        {{>createInstanceMustache}}{{>defaultValueMustache}},
      {{/isNamed}}
    {{/parameters}}
  );
{{/isCustomCall}}
''';

const createInstanceMustache = '''
{{{createInstanceCode}}}
''';
