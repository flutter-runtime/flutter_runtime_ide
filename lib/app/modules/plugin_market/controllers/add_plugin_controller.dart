import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPluginController extends GetxController {
  /// 插件地址输入框
  final TextEditingController urlController = TextEditingController();

  /// 插件引用输入框
  final TextEditingController refController = TextEditingController();

  /// 是否是本地插件
  var isLocalPlugin = false.obs;

  /// 是否覆盖
  var isOverwrite = false.obs;
}
