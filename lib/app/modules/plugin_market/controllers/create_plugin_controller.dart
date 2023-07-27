import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePluginController extends GetxController {
  /// 插件名称输入框
  final TextEditingController nameController = TextEditingController();

  /// 模板工程 Git 仓库的 Http 地址
  final TextEditingController urlController = TextEditingController();

  /// git ref
  final TextEditingController refController = TextEditingController();
}
