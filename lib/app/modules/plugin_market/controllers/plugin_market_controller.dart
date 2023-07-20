import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PluginMarketController extends GetxController {
  /// 插件名称的输入框
  final TextEditingController nameController = TextEditingController();

  /// 是否打开已安装插件列表
  var isShowInstalledPluginList = true.obs;

  /// 是否打开推荐插件列表
  var isShowRecommendPluginList = false.obs;
}
