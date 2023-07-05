import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_extension_controller.dart';
import 'package:get/get.dart';

import '../../../../analyzer/fix_runtime_configuration.dart';
import '../../../../common/common_function.dart';
import '../controllers/fix_method_controller.dart';
import 'fix_method_view.dart';
import 'fix_select_view.dart';

class FixExtensionView extends StatefulWidget {
  final FixExtensionController controller;
  const FixExtensionView(this.controller, {super.key});

  @override
  State<FixExtensionView> createState() => _FixExtensionViewState();
}

class _FixExtensionViewState extends State<FixExtensionView>
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
        title: const Text('修复扩展配置'),
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _addMethodConfig();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              leading: const Text('是否隐藏'),
              trailing: Obx(
                () => Switch(
                  value: widget.controller.isHide.value,
                  onChanged: (isOn) => widget.controller.setIsHide(isOn),
                ),
              ),
            ),
            const Divider(),
            TabBar(controller: _tabController, tabs: [
              Tab(
                  child: Text(
                'Method',
                style: TextStyle(color: Colors.blue.shade300),
              )),
            ]),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FixSelectView(
                    controller: widget.controller.selectMethodController,
                    onTap: (item) =>
                        Unwrap(item).map((e) => _showFixMethodView(e)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _addMethodConfig() async {
    final result =
        await showSelectItemDialog(widget.controller.allEmptyMethodConfig);
    if (result == null) return;
    widget.controller.addConfig(result);
  }

  _showFixMethodView(FixMethodConfig config) async {
    final element = widget.controller.getMethod(config.name);
    if (element == null) return;
    final controller = FixMethodController(config, element);
    Get.dialog(Dialog(child: FixMethodView(controller)));
  }
}
