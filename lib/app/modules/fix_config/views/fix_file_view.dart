import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
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

class FixFileView extends StatefulWidget {
  final FixFileController controller;
  const FixFileView({Key? key, required this.controller}) : super(key: key);

  @override
  State<FixFileView> createState() => _FixFileViewState();
}

class _FixFileViewState extends State<FixFileView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复文件配置'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddClassConfig();
              } else if (_tabController.index == 1) {
                _showAddExtensionConfig();
              } else if (_tabController.index == 2) {
                _showAddImportConfig();
              } else if (_tabController.index == 3) {
                _showAddMethodConfig();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Class',
                  style: TextStyle(color: Colors.blue.shade300),
                ),
              ),
              Tab(
                child: Text(
                  'Extension',
                  style: TextStyle(color: Colors.blue.shade300),
                ),
              ),
              Tab(
                child: Text(
                  'Import',
                  style: TextStyle(color: Colors.blue.shade300),
                ),
              ),
              Tab(
                child: Text(
                  'Method',
                  style: TextStyle(color: Colors.blue.shade300),
                ),
              )
            ],
            controller: _tabController,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  FixSelectView(
                    controller: widget.controller.selectClassController,
                    onTap: (item) => Unwrap(item).map((e) {
                      return _showFixClassView(e);
                    }),
                  ),
                  FixSelectView(
                    controller: widget.controller.selectExtensionController,
                    onTap: (item) => Unwrap(item).map((e) {
                      return _showFixExtensionView(e);
                    }),
                  ),
                  FixSelectView(
                    controller: widget.controller.selectImportController,
                    onTap: (item) => Unwrap(item).map((e) {
                      return _showFixImportView(e);
                    }),
                  ),
                  FixSelectView(
                    controller: widget.controller.selectMethodController,
                    onTap: (item) => Unwrap(item).map((e) {
                      return _showFixMethodView(e);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showFixClassView(FixClassConfig config) async {
    final element = widget.controller.getClassElement(config.name);
    if (element == null) return;
    final controller = FixClassController(config, element);
    Get.dialog(Dialog(child: FixClassView(controller)));
  }

  _showFixExtensionView(FixExtensionConfig config) async {
    final element = widget.controller.getExtensionElement(config.name);
    if (element == null) return;
    final controller = FixExtensionController(config, element);
    Get.dialog(Dialog(child: FixExtensionView(controller)));
  }

  _showFixImportView(FixImportConfig config) async {
    final element = widget.controller.getImportElement(config.path);
    if (element == null) return;
    final controller = FixImportController(config, element);
    Get.dialog(Dialog(child: FixImportView(controller)));
  }

  _showFixMethodView(FixMethodConfig config) async {
    final element = widget.controller.getFunctionElement(config.name);
    if (element == null) return;
    final controller = FixMethodController(config, element);
    Get.dialog(Dialog(child: FixMethodView(controller)));
  }

  _showAddClassConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyClassConfig);
    if (result == null) return;
    widget.controller.addClassConfig(result);
  }

  _showAddExtensionConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyExtensionConfig);
    if (result == null) return;
    widget.controller.addExtensionConfig(result);
  }

  _showAddImportConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyImportConfig);
    if (result == null) return;
    widget.controller.addImportConfig(result);
  }

  Future<void> _showAddMethodConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyMethodConfig);
    if (result == null) return;
    widget.controller.addMethodConfig(result);
  }
}
