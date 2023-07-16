class AnalyzeInfo {
  final AnalyzeInfoType infoType;
  final String message;
  AnalyzeInfo(this.infoType, this.message);
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
    if (message.isEmpty || index == stdoutLines.length - 1) {
      infos.add(AnalyzeInfo(infoType, message));
      infoType = null;
      message = '';
    } else {
      message += line;
    }
  }
  return infos;
}
