import 'package:darty_json_safe/darty_json_safe.dart';

abstract class AnalyzerCache<T> {
  final T element;
  bool isEnable = true;
  AnalyzerCache(this.element) {
    if (element is Map<String, dynamic>) {
      isEnable = JSON(element)['isEnabled'].boolValue;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnable': isEnable,
    };
  }
}
