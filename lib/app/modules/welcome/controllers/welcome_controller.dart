import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_runtime_ide/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeController extends GetxController {
  // 已经打开过的项目列表
  var projectPaths = <String>[].obs;
  // 存储在本地已经打开项目列表的 Key
  static const String projectPathsKey = "projectPaths";
  // 当前高亮的索引
  RxInt currentHighlightIndex = RxInt(-1);

  WelcomeController() {
    init();
  }

  Future<void> init() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    projectPaths.value = preferences.getStringList(projectPathsKey) ?? [];
  }

  // 打开 Flutter 项目
  Future<void> openExitProject() async {
    String? projectPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "请选择 Flutter 项目的路径",
    );
    if (projectPath == null) return;
    String pubspecFilePath = join(projectPath, "pubspec.yaml");
    if (!await File(pubspecFilePath).exists()) {
      Get.snackbar("错误", "你选择不是一个 Flutter 项目!");
      return;
    }

    // 判断工程是否已经存在
    if (projectPaths.contains(projectPath)) {
      projectPaths.remove(projectPath);
    }
    projectPaths.add(projectPath);
    sortProject(projectPath);
    goHome(projectPath);
  }

  // 点击了历史某一工程
  // @param projectPath 项目的路径
  void onClickHistoryItem(String projectPath) {
    sortProject(projectPath);
    goHome(projectPath);
  }

  // 前往首页
  // @param projectPath 项目的路径
  void goHome(String projectPath) {
    Get.toNamed(Routes.HOME, arguments: projectPath);
  }

  // 将指定的目录排序到第一位
  // @param projectPath 指定的目录
  void sortProject(String projectPath) {
    // 获取 projectPath 在数组所在的位置
    int index = projectPaths.indexOf(projectPath);
    projectPaths.removeAt(index);
    // 将最新的路径放在第一个
    projectPaths.insert(0, projectPath);
    _saveProjectPaths();
  }

  // 将已经打开过的项目列表保存在本地
  void _saveProjectPaths() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setStringList(projectPathsKey, projectPaths);
  }

  /// 删除对应的历史工程
  /// @param projectPath 历史工程的路径
  void deleteProjectPath(String projectPath) {
    projectPaths.remove(projectPath);
    _saveProjectPaths();
  }
}
