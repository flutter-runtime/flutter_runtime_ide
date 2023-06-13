const classMustache = '''
class \${{className}}\$ {

{{>getFieldMustache}}

}
''';

const fileMustache = '''
{{#classes}}
{{>classMustache}}
{{/classes}}
''';

const getFieldMustache = '''
dynamic get(String name) {
  {{#getFields}}
  if (name == "{{name}}") return '';
  {{/getFields}}
}
''';
