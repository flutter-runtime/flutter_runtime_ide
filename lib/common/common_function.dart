import 'package:logger/logger.dart';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart';

String getDartPath() {
  String dartCommandPath = whichSync("dart") ?? "";
  return join(dirname(dartCommandPath), "cache", "dart-sdk");
}

Logger logger = Logger(printer: PrettyPrinter());
