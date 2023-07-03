import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../app/modules/fix_config/views/fix_select_view.dart';

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

Future<T?> showSelectItemDialog<T extends FixSelectItem>(List<T> items) async {
  return Get.dialog<T>(
    Dialog(
      child: FixSelectView(
        controller: FixSelectController<T>(items, allowDelete: false),
        onTap: (item) => Get.back(result: item),
      ),
    ),
  );
}

String? libraryPath(String fullPath) {
  if (!fullPath.contains('/lib/')) return null;
  return fullPath.split('/lib/')[1];
}
