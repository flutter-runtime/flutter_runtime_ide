import 'dart:async';
import 'dart:convert';

import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:process_run/shell.dart';

class RunCommandController extends GetxController {
  final List<CommandRun> commands;
  var logs = <LogEvent>[].obs;
  var currentCommand = Rx<CommandRun?>(null);
  RunCommandController(this.commands) {
    _runCommands();
  }

  _runCommands() async {
    logCallBack(log) => logs.add(log);
    Logger.addLogListener(logCallBack);
    final stdoutController = StreamController<List<int>>();
    stdoutController.stream.listen((event) {
      String log = utf8.decode(event);
      logger.i(log);
    });
    final stderrController = StreamController<List<int>>();
    stderrController.stream.listen((event) {
      /// utf8  编码
      String log = utf8.decode(event);
      logger.e(log);
    });

    try {
      for (final command in commands) {
        currentCommand.value = command;
        await command.run(
          stdoutController: stdoutController,
          stderrController: stderrController,
        );
      }
    } catch (e) {
      logger.i(e.toString());
    }
    Logger.removeLogListener(logCallBack);
  }
}
