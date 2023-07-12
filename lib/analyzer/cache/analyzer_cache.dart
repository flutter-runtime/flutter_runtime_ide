import 'package:darty_json_safe/darty_json_safe.dart';

abstract class AnalyzerCache<T> {
  final T element;
  final Map<String, dynamic> map;
  bool isEnable = true;
  AnalyzerCache(this.element, this.map) {
    fromMap(map);
  }

  Map<String, dynamic> toJson() {
    addToMap();
    return map;
  }

  void addToMap() {
    this['isEnable'] = isEnable;
  }

  operator []=(String name, dynamic element) {
    Unwrap(element).map((e) => map[name] = e);
  }

  void fromMap(Map<String, dynamic> map) {
    isEnable = JSON(element)['isEnabled'].bool ?? true;
  }
}
