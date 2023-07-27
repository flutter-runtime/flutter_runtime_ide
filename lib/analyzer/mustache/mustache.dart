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
// ignore_for_file: implementation_imports, unused_import, invalid_use_of_visible_for_testing_member, duplicate_import, deprecated_member_use, unused_shown_name, camel_case_types, 
import 'dart:async';
import 'package:flutter_runtime/flutter_runtime.dart';
import 'package:darty_json_safe/darty_json_safe.dart';
{{#paths}}
{{>importMustache}}
{{/paths}}

{{#classes}}
{{>classMustache}}
{{/classes}}
''';

const getFieldMustache = '''
@override
dynamic getField(
    FlutterRuntimeCallPath callPath,
    String fieldName,
) {
  {{#getFields}}
  {{#isStatic}}
  if (fieldName == "{{fieldName}}") return {{{staticPrefix}}}{{fieldValue}};
  {{/isStatic}}
  {{^isStatic}}
  if (fieldName == "{{fieldName}}") return {{{prefix}}}{{fieldValue}};
  {{/isStatic}}
  {{/getFields}}
  {{#isGlobal}}
  {{#runtimeNames}}
  if (callPath.className == r'{{{runtimeName}}}') return {{{runtimeName}}}(callPath.runtime).getField(callPath,fieldName);
  {{/runtimeNames}}
  {{/isGlobal}}
}
''';

const setFieldMustache = '''
@override
void setField(
    FlutterRuntimeCallPath callPath,
    String fieldName,
    dynamic value,
  ) {
  {{#setFields}}
    {{#isStatic}}
      if (fieldName == "{{fieldName}}") {{>prefixMustache}}{{fieldValue}} = value;
    {{/isStatic}}
    {{^isStatic}}
      if (fieldName == "{{fieldName}}") {{>prefixMustache}}{{fieldValue}} = value;
    {{/isStatic}}
  {{/setFields}}
  {{#isGlobal}}
  {{#runtimeNames}}
  if (callPath.className == r'{{{runtimeName}}}')  {{{runtimeName}}}(callPath.runtime).setField(callPath,fieldName,value);
  {{/runtimeNames}}
  {{/isGlobal}}
}
''';

const methodMustache = '''
@override
dynamic call(
    FlutterRuntimeCallPath callPath,
    String methodName, [
    Map args = const {},
  ]) {
  {{#methods}}
  {{>functionMustache}}
  {{/methods}}
  {{#isGlobal}}
  {{#runtimeNames}}
  if (callPath.className == r'{{{runtimeName}}}') return {{{runtimeName}}}(callPath.runtime).call(callPath,methodName,args);
  {{/runtimeNames}}
  {{/isGlobal}}
}
''';

const constructorMustache = '''
@override
dynamic createInstance(
    FlutterRuntimeCallPath callPath,
    String constructorName, [
    Map args = const {},
  ]) {
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
  {{#isGlobal}}
  {{#runtimeNames}}
  if (callPath.className == r'{{{runtimeName}}}') return {{{runtimeName}}}(callPath.runtime).createInstance(callPath,constructorName,args);
  {{/runtimeNames}}
  {{/isGlobal}}
  return null;
} 
''';

const defaultValueMustache = '''
{{#hasDefaultValue}}
  ?? {{{defaultValueCode}}}
{{/hasDefaultValue}}
''';

const pubspecMustache = '''
name: {{{runtimeName}}}
environment:
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  flutter_runtime:
    git:
      url: https://github.com/flutter-runtime/flutter_runtime.git
      ref: 0.1.0
  darty_json_safe: ^1.0.1
{{#override}}
dependency_overrides:
  {{pubName}}:
    path: {{{pubPath}}}
{{/override}}
''';

const functionMustache = '''
{{#isCustomCall}}
  if (methodName == '{{{callMethodName}}}') return {{{customCallCode}}};
{{/isCustomCall}}
{{^isCustomCall}}
  if (methodName == '{{{callMethodName}}}') return {{>prefixMustache}}{{{methodName}}}(
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

const prefixMustache = '''
{{#isStatic}}
{{{staticPrefix}}}
{{/isStatic}}
{{^isStatic}}
{{{prefix}}}
{{/isStatic}}
''';

const importMustache = '''
import '{{{uriContent}}}'
{{#hasAsName}} as {{asName}}{{/hasAsName}}
{{#hasShowNames}} show {{{showContent}}}{{/hasShowNames}} 
{{#hasHideNames}} hide {{{hideContent}}}{{/hasHideNames}} 
;
''';

const globaleRuntimePackageMustache = '''
name: {{{pubName}}}
environment:
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  {{#dependencies}}
  {{name}}:
    path: {{{path}}}
  {{/dependencies}}
''';
