import 'dart:convert';
import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:dcm/dcm.dart';
import 'package:flutter_runtime_ide/analyzer/analyzer_package_manager.dart';
import 'package:flutter_runtime_ide/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

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
  Future<List<CommandInfo>> allInstalled(String projectPath) async {
    try {
      final result = await listCommand.run();
      final allCli =
          JSON(result.stdout).listValue.map((e) => Cli.fromJson(e)).toList();
      final activePlugins = await loadActivePlugins(projectPath);
      final commandInfos = await Future.wait(allCli.map((e) async {
        final pubYamlPath = join(e.installPath, 'pubspec.yaml');
        final yaml = await File(pubYamlPath)
            .readAsString()
            .then((value) => PubspecYaml.loadFromYamlString(value));
        return CommandInfo(e, yaml)
          ..isActive = activePlugins.any((element) {
            return element.name == e.name && element.ref == e.ref;
          });
      }).toList());
      return commandInfos;
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

  /// 读取已经激活的插件列表
  Future<List<ActivePluginInfo>> loadActivePlugins(String projectPath) async {
    final file = File(activePluginPath(projectPath));
    if (!await file.exists()) return [];
    return file.readAsString().then((value) => JSON(json.decode(value))
        .listValue
        .map((e) => ActivePluginInfo.fromJson(e))
        .toList());
  }

  /// 保存已经激活的插件列表
  Future<void> saveActivePlugins(
      List<ActivePluginInfo> plugins, String projectPath) async {
    final file = File(activePluginPath(projectPath));
    await file.writeAsString(const JsonEncoder.withIndent(' ')
        .convert(plugins.map((e) => e.toJson()).toList()));
  }

  /// 存储在本地已经激活的插件列表文件路径
  String activePluginPath(String projectPath) {
    return join(projectPath, '.active_plugins.json');
  }

  /// 获取存在在项目配置自定义版本
  String versionPath(String projectPath) {
    return join(projectPath, '.versions.json');
  }

  /// 获取配置的版本列表
  Future<List<Version>> getVersions(String projectPath) async {
    final file = File(versionPath(projectPath));
    if (!await file.exists()) return [];
    return file.readAsString().then((value) => JSON(json.decode(value))
        .listValue
        .map((e) => Version.fromJson(e))
        .toList());
  }

  /// 保存配置的版本列表
  Future<void> saveVersions(List<Version> versions, String projectPath) async {
    final file = File(versionPath(projectPath));
    await file.writeString(const JsonEncoder.withIndent(' ')
        .convert(versions.map((e) => e.toJson()).toList()));
  }

  /// 重新编译的插件命令
  CommandRun rebuildCommand(CommandInfo info) {
    return CommandRun(
      'dcm',
      'rebuild -n ${info.cli.name} -r ${info.cli.ref}',
    );
  }
}

class CommandInfo {
  final Cli cli;
  final PubspecYaml yaml;

  /// 是否激活
  bool isActive = false;

  /// 是否开发模式
  bool isDeveloper = false;

  String developerPath;

  CommandInfo(this.cli, this.yaml) : developerPath = cli.installPath;

  /// 获取描述
  String get description => yaml.description.unsafe ?? '';

  /// 获取命令支持的方法
  List<CommandFunction> get functions => JSON(yaml.customFields)['commands']
      .mapValue
      .entries
      .map((e) => CommandFunction(e.key, e.value))
      .toList();
}

class CommandFunction {
  final String name;
  final Map parameters;
  CommandFunction(this.name, this.parameters);
}

/// 激活的插件信息
class ActivePluginInfo {
  late String name;
  late String ref;

  ActivePluginInfo();

  ActivePluginInfo.fromJson(Map<String, dynamic> map) {
    final json = JSON(map);
    name = json['name'].stringValue;
    ref = json['ref'].stringValue;
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'ref': ref};
  }
}
