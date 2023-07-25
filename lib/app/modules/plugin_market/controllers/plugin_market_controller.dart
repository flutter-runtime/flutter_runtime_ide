import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:flutter_runtime_ide/widgets/run_command/run_command_view.dart';
import 'package:flutter_runtime_ide/widgets/run_command/run_conmand_controller.dart';
import 'package:get/get.dart';
import 'package:dcm/dcm.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';

class PluginMarketController extends GetxController {
  /// 插件名称的输入框
  final TextEditingController nameController = TextEditingController();

  /// 是否打开已安装插件列表
  var isShowInstalledPluginList = true.obs;

  /// 是否打开推荐插件列表
  var isShowRecommendPluginList = false.obs;

  /// 已经安装的插件列表
  var installedPlugins = <CommandInfo>[].obs;

  // 当前选中的插件
  var currentPluginInfo = Rxn<CommandInfo>();

  PluginMarketController() {
    _loadInstalledClis();
  }

  /// 当前选中插件的索引 没有选中返回-1
  int get currentPluginIndex => Unwrap(currentPluginInfo.value)
      .map((e) => installedPlugins.indexOf(e))
      .defaultValue(-1);

  /// 加载已安装的插件
  _loadInstalledClis() async {
    final allCli = await CliVersionManager().allInstalled();
    final commandInfos = await Future.wait(allCli.map((e) async {
      final pubYamlPath = join(e.installPath, 'pubspec.yaml');
      final yaml = await File(pubYamlPath)
          .readAsString()
          .then((value) => PubspecYaml.loadFromYamlString(value));
      return CommandInfo(e, yaml);
    }).toList());
    installedPlugins.value = commandInfos;
    isShowInstalledPluginList.value = installedPlugins.isNotEmpty;
  }

  /// 添加插件
  /// [url] 插件地址
  /// [ref] 插件引用
  /// [isLocal] 是否本地
  Future<void> addPlugin(
    String url,
    String ref, [
    bool isLocal = false,
    bool isOverwrite = false,
  ]) async {
    CommandRun commandRun;
    if (isLocal) {
      var command = 'local -p $url';
      if (isOverwrite) {
        command += ' -f';
      }
      commandRun = CommandRun('dcm', command);
    } else {
      var command = 'install -p $url@$ref';
      if (isOverwrite) {
        command += ' -f';
      }
      commandRun = CommandRun('dcm', command);
    }
    Get.dialog(
      Dialog(child: RunCommandView(RunCommandController([commandRun]))),
    );
  }

  /// 创建插件
  Future<void> createPlugin(String name, String url, String ref) async {
    Get.dialog(Dialog(
      child: RunCommandView(RunCommandController([
        CommandRun(
          'dcm',
          'create -n $name -u $url -r $ref',
          workingDirectory: platformEnvironment['HOME'],
        ),
        CommandRun(
          'flutter',
          'pub get',
          workingDirectory: join(platformEnvironment['HOME']!, name),
        ),
      ])),
    ));
  }

  void updateInfo(CommandInfo info) {
    currentPluginInfo.value = info;
  }
}

class CommandInfo {
  final Cli cli;
  final PubspecYaml yaml;
  const CommandInfo(this.cli, this.yaml);

  String get description => yaml.description.unsafe ?? '';
}

class CommandFunction {
  final String name;
  final Map parameters;
  CommandFunction(this.name, this.parameters);
}
