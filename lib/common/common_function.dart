import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart' as crypto;

String getDartPath() {
  String dartCommandPath = whichSync("dart") ?? "";
  return join(dirname(dartCommandPath), "cache", "dart-sdk");
}

Logger logger = Logger(
  printer: PrettyPrinter(),
  output: ConsoleOutput(),
);

String md5(String source) {
  return crypto.md5.convert(utf8.encode(source)).toString().toString();
}
