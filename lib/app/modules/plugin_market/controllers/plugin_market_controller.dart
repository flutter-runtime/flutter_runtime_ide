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
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';

class PluginMarketController extends GetxController {
  /// 插件名称的输入框
  final TextEditingController nameController = TextEditingController();

  /// 是否打开已安装插件列表
  var isShowInstalledPluginList = true.obs;

  /// 是否打开推荐插件列表
  var isShowRecommendPluginList = false.obs;

  /// 已经安装的插件列表
  var installedPlugins = <Rx<CommandInfo>>[];

  // 当前选中的插件
  var currentPluginInfo = Rxn<CommandInfo>();

  /// 插件名称列表
  var pluginNames = <String>[].obs;

  final String projectPath;

  PluginMarketController(this.projectPath);

  @override
  void onReady() {
    super.onReady();
    _loadInstalledClis();
  }

  /// 当前选中插件的索引 没有选中返回-1
  int get currentPluginIndex => Unwrap(currentPluginInfo.value)
      .map((e) => installedPlugins.map((e) => e.value).toList().indexOf(e))
      .defaultValue(-1);

  /// 加载已安装的插件
  _loadInstalledClis() async {
    showHUD();
    final commandInfos = await PluginManager().allInstalled(projectPath);
    installedPlugins = commandInfos.map((e) => e.obs).toList();
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
  List<Rx<CommandInfo>> getInstalledVersion(String name) {
    return installedPlugins
        .where((element) => element.value.cli.name == name)
        .toList();
  }

  Future<void> activePlugin(Rx<CommandInfo> info) async {
    bool active = info.value.activePluginInfo != null;

    /// 其他的版本失去激活
    for (var infoR in installedPlugins) {
      if (infoR == info) {
        setPluginActive(!active, info);
      } else {
        setPluginActive(false, info);
      }
    }

    currentPluginInfo.value = !active ? info.value : null;

    await updateActivePluginCache();
  }

  setPluginActive(bool active, Rx<CommandInfo> info) {
    info.update((val) {
      final activeInfo = ActivePluginInfo()
        ..name = info.value.cli.name
        ..ref = info.value.cli.ref
        ..developerPath = info.value.cliPath;
      val?.activePluginInfo = active ? activeInfo : null;
    });
  }

  /// 更新激活插件的参数保存在本地
  updateActivePluginCache() async {
    /// 获取当前已经激活的列表
    final plugins = installedPlugins
        .map((e) => e.value)
        .map((element) => element.activePluginInfo)
        .whereType<ActivePluginInfo>()
        .toList();
    showHUD();
    await PluginManager().saveActivePlugins(plugins, projectPath);
    hideHUD();
  }

  switchDeveloper(bool isDeveloper) async {
    currentPluginInfo.update((val) {
      val?.activePluginInfo?.isDeveloper = isDeveloper;
    });
    await updateActivePluginCache();
  }

  switchDeveloperPath(CommandInfo info, String value) async {
    currentPluginInfo.update((val) {
      val?.activePluginInfo?.developerPath = value;
    });
    await updateActivePluginCache();
  }

  /// 点击打开或者关闭插件列表
  /// 如果打开插件列表 则展示当前激活的插件
  /// 如果关闭插件列表 则关闭展示当前激活的插件
  onExpansionChanged(bool value, List<Rx<CommandInfo>> versions) {
    currentPluginInfo.value = versions
        .map((e) => e.value)
        .toList()
        .firstWhereOrNull(
            (element) => element.activePluginInfo != null && value);
  }

  /// 重新编译脚本
  rebuild(CommandInfo info) async {
    await Get.dialog(
      RunCommandView(RunCommandController(
        [PluginManager().rebuildCommand(info)],
      )),
    );
  }
}
