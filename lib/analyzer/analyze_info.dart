import 'package:darty_json_safe/darty_json_safe.dart';

class AnalyzeInfo {
  final AnalyzeInfoType infoType;
  final String message;
  AnalyzeInfo(this.infoType, this.message);

  /// 分析的内容
  String get messageContent => JSON(_messageContentList)[1].stringValue;

  /// 分析所在的文件地址
  String get filePath => JSON(_fileContentList)[0].stringValue;

  /// 分析所在的行
  String get line => JSON(_fileContentList)[1].stringValue;

  /// 分析所在列的位置
  String get column => JSON(_fileContentList)[2].stringValue;

  /// 分析的  lint  语意
  String get lint => JSON(_messageContentList)[3].stringValue;

  /// 获取通过 • 分割的文本数据
  /// 第一个包含分析的类型  info/warning/error
  /// 第二个包含分析的内容
  /// 第三个包含分析的位置
  /// 第四个包含分析的 Lint  来源
  List<String> get _messageContentList {
    return message.split('•');
  }

  /// 获取通过 : 分析文本文本信息
  /// 第一个包含文件路径地址
  /// 第二个包含在文件行数
  /// 第三个包含在行所在的代码位置
  List<String> get _fileContentList {
    return JSON(_messageContentList)[2].stringValue.split(':');
  }
}

enum AnalyzeInfoType { error, warning, info }

List<AnalyzeInfo> parseAnalyzeInfos(Iterable<String> stdoutLines) {
  List<AnalyzeInfo> infos = [];
  AnalyzeInfoType? infoType;
  String message = '';
  int index = -1;
  for (var line in stdoutLines) {
    index++;
    if (line.contains('error •')) {
      infoType = AnalyzeInfoType.error;
    } else if (line.contains('warning •')) {
      infoType = AnalyzeInfoType.warning;
    } else if (line.contains('info •')) {
      infoType = AnalyzeInfoType.info;
    }
    if (infoType == null) continue;
    if (message.isNotEmpty || index == stdoutLines.length - 1) {
      infos.add(AnalyzeInfo(infoType, message));
      infoType = null;
      message = '';
    } else {
      message += line;
    }
  }
  return infos;
}
