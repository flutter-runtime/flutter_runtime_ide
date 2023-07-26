import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../../../common/plugin_manager.dart';

class ChoosePluginVersionController extends GetxController {
  final CommandInfo info;

  /// 分支列表
  var branchs = <String>[].obs;

  /// tag  列表
  var tags = <String>[].obs;

  /// 引用输入框
  final refTextFieldController = TextEditingController();

  ChoosePluginVersionController(this.info);

  @override
  void onReady() async {
    super.onReady();
    showHUD();
    branchs.value = await PluginManager().allBranchs(info).then((value) {
      return value
          .map((e) => basename(e))
          .toSet()
          .where((element) => element != 'HEAD')
          .toList();
    });

    tags.value = await PluginManager().allTags(info).then((value) {
      return value.where((element) => element.isNotEmpty).toList();
    });
    hideHUD();
  }
}
