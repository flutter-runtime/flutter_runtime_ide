import 'dart:async';
import 'dart:io';
import 'package:process_run/process_run.dart';

class CommandRun {
  final String command;
  final String commandArg;
  final String? workingDirectory;
  final Map<String, String>? environment;
  CommandRun(
    this.command,
    this.commandArg, {
    this.workingDirectory,
    this.environment,
  });

  Future<ProcessResult> run({
    StreamController<List<int>>? stdoutController,
    StreamController<List<int>>? stderrController,
  }) async {
    final commandPath = await which(command);
    if (commandPath == null) {
      throw Exception('Command not found: $command');
    }

    final shell = Shell(
      workingDirectory: workingDirectory,
      environment: environment,
      stdout: stdoutController?.sink,
      stderr: stderrController?.sink ?? stdoutController?.sink,
    );
    return shell.run('$commandPath $commandArg').then((value) => value.first);
  }
}
