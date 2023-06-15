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
    if (name == "classMustache") {
      return Template(classMustache);
    } else if (name == "getFieldMustache") {
      return Template(getFieldMustache);
    } else if (name == "methodMustache") {
      return Template(methodMustache);
    } else {
      throw UnsupportedError("Unsupported partial: $name");
    }
  }
}
