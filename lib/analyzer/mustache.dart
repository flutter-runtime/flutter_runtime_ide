const classMustache = '''
class {{className}} extends FlutterRuntime<{{{runtimeType}}}>{

{{className}}(super.runtime);

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
  if (fieldName == "{{fieldName}}") return {{{staticPrefix}}}{{fieldValue}};
  {{/isStatic}}
  {{^isStatic}}
  if (fieldName == "{{fieldName}}") return {{{prefix}}}{{fieldValue}};
  {{/isStatic}}
  {{/getFields}}
}
''';

const setFieldMustache = '''
@override
void setField(String fieldName, dynamic value) {
  {{#setFields}}
    {{#isStatic}}
      if (fieldName == "{{fieldName}}") {{{prefix}}}{{fieldValue}} = value;
    {{/isStatic}}
    {{^isStatic}}
      if (fieldName == "{{fieldName}}") {{{prefix}}}{{fieldValue}} = value;
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

{{{runtimeType}}}? createRuntimeInstance(String constructorName,[Map args = const {},]) {
  {{^isAbstract}}
    {{#constructors}}
      if (constructorName == "{{constructorName}}")
        return {{runtimeType}}{{#isName}}.{{constructorName}}{{/isName}}(
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
  ?? {{{defaultValueCode}}}
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

const functionMustache = '''
{{#isCustomCall}}
  if (methodName == '{{methodName}}') return {{{customCallCode}}};
{{/isCustomCall}}
{{^isCustomCall}}
  if (methodName == '{{methodName}}') return {{{prefix}}}{{methodName}}(
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
