import 'dart:convert';
import 'dart:io';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/choose_plugin_version_controller.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/choose_plugin_version_view.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/command_run.dart';
import 'package:flutter_runtime_ide/common/plugin_manager.dart';
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
  var installedPlugins = <CommandInfo>[];

  // 当前选中的插件
  var currentPluginInfo = Rxn<CommandInfo>();

  /// 插件名称列表
  var pluginNames = <String>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadInstalledClis();
  }

  /// 当前选中插件的索引 没有选中返回-1
  int get currentPluginIndex => Unwrap(currentPluginInfo.value)
      .map((e) => installedPlugins.indexOf(e))
      .defaultValue(-1);

  /// 加载已安装的插件
  _loadInstalledClis() async {
    showHUD();
    final allCli = await PluginManager().allInstalled();
    final activePlugins = await _loadActivePlugins();
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

    installedPlugins = commandInfos;
    pluginNames.value = commandInfos.map((e) => e.cli.name).toSet().toList();

    isShowInstalledPluginList.value = installedPlugins.isNotEmpty;

    Unwrap(currentPluginInfo.value).map((e) {
      final info = commandInfos.firstWhereOrNull((element) =>
          element.cli.url == e.cli.url && element.cli.ref == e.cli.ref);
      updateInfo(info);
    });

    hideHUD();
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
    await Get.dialog(
      Dialog(child: RunCommandView(RunCommandController([commandRun]))),
    );
    await _loadInstalledClis();
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

  void updateInfo(CommandInfo? info) {
    currentPluginInfo.value = info;
  }

  /// 点击卸载按钮
  Future<void> uninstallPlugin(CommandInfo info) async {
    await Get.dialog(
      RunCommandView(
        RunCommandController([PluginManager().uninstallPluginCommand(info)]),
      ),
    );

    await _loadInstalledClis();
  }

  /// 重新安装插件
  Future<void> reinstallPlugin(CommandInfo info) async {
    await Get.dialog(
      RunCommandView(
        RunCommandController([
          PluginManager().reinstallCommand(info),
        ]),
      ),
    );
    await _loadInstalledClis();
  }

  /// 安装其他版本
  Future<void> installOtherVersion(CommandInfo info) async {
    /// 检测安装的是否是一个 Git  项目
    final gitDir = join(info.cli.installPath, '.git');
    if (!await Directory(gitDir).exists()) {
      Get.snackbar('错误!', '当前插件不是一个 Git 项目');
      return;
    }
    final result = await Get.dialog<String>(Dialog(
      child: ChoosePluginVersionView(ChoosePluginVersionController(info)),
    ));
    if (result == null) return;
    await Get.dialog(RunCommandView(RunCommandController([
      PluginManager().getInstallCommand(info.cli.url, result),
    ])));
    await _loadInstalledClis();
  }

  /// 根据插件名称查出当前已经安装的版本
  List<CommandInfo> getInstalledVersion(String name) {
    return installedPlugins
        .where((element) => element.cli.name == name)
        .toList();
  }

  /// 存储在本地已经激活的插件列表文件路径
  String get activePluginPath {
    return join(platformEnvironment['HOME']!, '.active_plugins.json');
  }

  /// 读取已经激活的插件列表
  Future<List<ActivePluginInfo>> _loadActivePlugins() async {
    final file = File(activePluginPath);
    if (!await file.exists()) return [];
    return file.readAsString().then((value) => JSON(json.decode(value))
        .listValue
        .map((e) => ActivePluginInfo.fromJson(e))
        .toList());
  }

  /// 保存已经激活的插件列表
  Future<void> _saveActivePlugins(List<ActivePluginInfo> plugins) async {
    final file = File(activePluginPath);
    await file
        .writeAsString(json.encode(plugins.map((e) => e.toJson()).toList()));
  }

  Future<void> activePlugin(CommandInfo info, bool isActive) async {}
}

class CommandInfo {
  final Cli cli;
  final PubspecYaml yaml;

  /// 是否激活
  bool isActive = false;

  CommandInfo(this.cli, this.yaml);

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
  ActivePluginInfo.fromJson(Map<String, dynamic> map) {
    final json = JSON(map);
    name = json['name'].stringValue;
    ref = json['ref'].stringValue;
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'ref': ref};
  }
}
