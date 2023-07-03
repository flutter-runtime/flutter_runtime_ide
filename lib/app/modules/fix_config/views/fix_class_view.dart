import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_class_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_method_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/add_name_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';

import 'package:get/get.dart';

import 'fix_method_view.dart';

class FixClassView extends StatefulWidget {
  final FixClassController controller;
  const FixClassView({Key? key, required this.controller}) : super(key: key);

  @override
  State<FixClassView> createState() => _FixClassViewState();
}

class _FixClassViewState extends State<FixClassView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FixClassView'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddClassConfig(),
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
                  style: TextStyle(color: Colors.green.shade300),
                ),
              )
            ],
            controller: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FixSelectView(
                  controller: widget.controller.selectController,
                  onTap: (item) => Unwrap(item).map((e) {
                    return _showFixMethodView(e);
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showFixMethodView(FixClassConfig config) async {
    final element = widget.controller.getElement(config.name);
    if (element == null) return;
    final controller = FixMethodController(config, element);
    Get.dialog(Dialog(child: FixMethodView(controller)));
  }

  _showAddClassConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyClassConfig);
    if (result == null) return;
    widget.controller.addConfig(result);
  }
}
