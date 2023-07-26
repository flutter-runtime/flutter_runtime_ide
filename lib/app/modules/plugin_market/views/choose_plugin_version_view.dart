import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/choose_plugin_version_controller.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:get/get.dart';

class ChoosePluginVersionView extends StatefulWidget {
  final ChoosePluginVersionController controller;
  const ChoosePluginVersionView(this.controller, {super.key});

  @override
  State<ChoosePluginVersionView> createState() =>
      _ChoosePluginVersionViewState();
}

class _ChoosePluginVersionViewState extends State<ChoosePluginVersionView>
    with TickerProviderStateMixin {
  PluginMarketController get controller => Get.find(tag: 'PluginMarketView');
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Get.put(widget.controller);
    return Scaffold(
      appBar: AppBar(title: const Text('选择版本')),
      body: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              labelColor: Colors.blue.shade400,
              indicatorColor: Colors.blue.shade400,
              tabs: const [
                Tab(text: 'Branch'),
                Tab(text: 'Tag'),
                Tab(text: 'Commit'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  Obx(() => _branchView(context, widget.controller.branchs)),
                  Obx(() => _branchView(context, widget.controller.tags)),
                  _refView(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _branchView(BuildContext context, List<String> values) {
    return ListView.separated(
      itemCount: values.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
      itemBuilder: (BuildContext context, int index) {
        return CupertinoListTile(
          title: Text(values[index]),
          onTap: () {
            Get.back(result: values[index]);
          },
        );
      },
    );
  }

  Widget _refView(BuildContext context) {
    return Column(
      children: [
        CupertinoListTile(
          title: TextField(
            decoration: const InputDecoration(labelText: '请输入 git ref'),
            controller: widget.controller.refTextFieldController,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {
                final ref = widget.controller.refTextFieldController.text;
                if (ref.isEmpty) {
                  return;
                }
                Get.back(result: ref);
              },
              child: const Text('提交')),
        )
      ],
    );
  }
}
