import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_class_cache.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_tab_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';

import 'package:get/get.dart';

import '../controllers/fix_class_controller.dart';
import '../controllers/fix_extension_controller.dart';
import '../controllers/fix_file_controller.dart';
import '../controllers/fix_import_controller.dart';
import '../controllers/fix_method_controller.dart';
import 'fix_class_view.dart';
import 'fix_extension_view.dart';
import 'fix_import_view.dart';
import 'fix_method_view.dart';

class FixFileView extends StatelessWidget {
  final FixFileController controller;
  const FixFileView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复文件配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FixTabView(controller.tabController),
      ),
    );
  }
}
