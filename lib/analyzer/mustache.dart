const classMustache = '''
class \${{className}}\$ extends FlutterRuntime<{{className}}>{

\${{className}}\$(super.runtime);

{{>getFieldMustache}}

{{>setFieldMustache}}

{{>methodMustache}}

{{>constructorMustache}}

@override
String get libraryPath => '{{{sourcePath}}}';

@override
String get packageName => '{{pubName}}';

}
''';

const fileMustache = '''
import 'dart:async';
import 'package:flutter_runtime/flutter_runtime.dart';
import 'package:{{pubName}}{{{sourcePath}}}';

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
  if (methodName == '{{methodName}}') return runtime.{{methodName}}(
    {{#parameters}}
      {{#isNamed}}
        {{parameterName}}:createInstance("{{className}}",args["{{parameterName}}"]),
      {{/isNamed}}
      {{^isNamed}}
        createInstance("{{className}}",args["{{parameterName}}"]),
      {{/isNamed}}
    {{/parameters}}
  );
  {{/methods}}
}
''';

const constructorMustache = '''

{{className}}? createRuntimeInstance(String constructorName,[Map args = const {}]) {
  {{^isAbstract}}
    {{#constructors}}
      if (constructorName == "constructorName")
        return {{className}}{{#isName}}.{{constructorName}}{{/isName}}(
          {{#parameters}}
            {{#isNamed}}
              {{parameterName}}:createInstance("{{className}}",args["{{parameterName}}"]),
            {{/isNamed}}
            {{^isNamed}}
              createInstance("{{className}}",args["{{parameterName}}"]),
            {{/isNamed}}
          {{/parameters}}
        );
    {{/constructors}}
  {{/isAbstract}}
  return null;
} 
''';

const pubspecMustache = '''
name: {{pubName}}_runtime
environment:
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  flutter_runtime:
    path: /Users/king/Documents/flutter_runtime
  {{pubName}}:
    path: {{{pubPath}}}
''';
