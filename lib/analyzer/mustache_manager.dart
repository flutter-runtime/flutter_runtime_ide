import 'package:flutter_runtime_ide/analyzer/mustache.dart';
import 'package:mustache_template/mustache.dart';

class MustacheManager {
  String render(String templateContent, Map<String, dynamic> values) {
    Template template = Template(
      templateContent,
      partialResolver: partialResolver,
    );
    return template.renderString(values);
  }

  Template? partialResolver(String name) {
    if (mustaches.keys.contains(name)) return Template(mustaches[name]!);
    throw UnsupportedError("Unsupported partial: $name");
  }

  Map<String, String> get mustaches => {
        "classMustache": classMustache,
        "getFieldMustache": getFieldMustache,
        "methodMustache": methodMustache,
        "setFieldMustache": setFieldMustache,
        "constructorMustache": constructorMustache,
        "defaultValueMustache": defaultValueMustache,
        "functionMustache": functionMustache,
        "createInstanceMustache": createInstanceMustache,
        'prefixMustache': prefixMustache,
        'importMustache': importMustache,
      };
}
