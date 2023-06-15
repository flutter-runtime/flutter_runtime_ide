const classMustache = '''
class \${{className}}\$ extends FlutterRuntime<{{className}}>{

\${{className}}\$(super.runtime);

{{>getFieldMustache}}

{{>methodMustache}}

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

const methodMustache = '''
@override
FutureOr call(String methodName,[Map args = const {}]) {
  {{#methods}}
  if (methodName == '{{methodName}}') return runtime.{{methodName}}(
    {{#parameters}}
    {{parameterName}}:createInstance("",args["{{parameterName}}"])
    {{/parameters}}
  );
  {{/methods}}
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
