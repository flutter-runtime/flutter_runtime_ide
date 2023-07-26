import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:dcm/dcm.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:process_run/process_run.dart';

class PluginManager {
  static final PluginManager _pluginManager = PluginManager._internal();
  PluginManager._internal();
  factory PluginManager() => _pluginManager;

  /// 卸载插件
  Future<void> uninstallPlugin(CommandInfo info) async {
    await runCommand(uninstallPluginCommand(info));
  }

  CommandRun uninstallPluginCommand(CommandInfo info) {
    return CommandRun(
      'dcm',
      'uninstall -n ${info.cli.name}@${info.cli.ref}',
    );
  }

  Future<ProcessResult?> runCommand(CommandRun commandRun) async {
    try {
      return await commandRun.run();
    } on ShellException catch (e) {
      throw e.result?.stdout;
    } catch (e) {
      throw e.toString();
    }
  }

  /// 获取已经安装的插件列表
  Future<List<Cli>> allInstalled() async {
    try {
      final result = await listCommand.run();
      return JSON(result.stdout).listValue.map((e) => Cli.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取安装路径所有的分支名称
  Future<List<String>> allBranchs(CommandInfo info) async {
    try {
      final result = await runCommand(getBranchCommand(info));
      return JSON(result?.stdout).listValue.map((e) => e as String).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取安装路径所有的 Tag
  Future<List<String>> allTags(CommandInfo info) async {
    try {
      final result = await runCommand(getTagCommand(info));
      return JSON(result?.stdout).listValue.map((e) => e as String).toList();
    } catch (e) {
      return [];
    }
  }

  CommandRun get listCommand => CommandRun('dcm', 'list -j');

  /// 重新安装命令
  CommandRun reinstallCommand(CommandInfo info) {
    if (info.cli.isLocal) {
      return CommandRun('dcm', 'local -p ${info.cli.url} -f');
    } else {
      return CommandRun('dcm', 'install -p ${info.cli.url}@${info.cli.ref}');
    }
  }

  /// 获取当前插件所有分支的命令
  CommandRun getBranchCommand(CommandInfo info) {
    return CommandRun(
      'dcm',
      'get_all_branch -n ${info.cli.name} -r ${info.cli.ref}',
    );
  }

  /// 获取所有  Tag 的命令
  CommandRun getTagCommand(CommandInfo info) {
    return CommandRun(
      'dcm',
      'get_all_tag -n ${info.cli.name} -r ${info.cli.ref}',
    );
  }

  /// 安装插件命令
  CommandRun getInstallCommand(String url, String ref) {
    return CommandRun('dcm', 'install -p $url@$ref -f');
  }
}
