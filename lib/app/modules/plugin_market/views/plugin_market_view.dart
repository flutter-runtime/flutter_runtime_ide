import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/add_plugin_controller.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/add_plugin_view.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/command_detail_view.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/create_plugin_view.dart';
import 'package:get/get.dart';

import '../controllers/create_plugin_controller.dart';
import '../controllers/plugin_market_controller.dart';

class PluginMarketView extends StatefulWidget {
  final PluginMarketController controller;
  const PluginMarketView(this.controller, {Key? key}) : super(key: key);

  @override
  State<PluginMarketView> createState() => _PluginMarketViewState();
}

class _PluginMarketViewState extends State<PluginMarketView> {
  @override
  void initState() {
    super.initState();
    Get.put(tag: 'PluginMarketView', widget.controller);
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete(tag: 'PluginMarketView');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件市场'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _createPlugin(),
            icon: const Icon(Icons.queue),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
              width: 500,
              color: Colors.blue.shade100,
              child: Obx(
                () => Column(
                  children: [
                    CupertinoListTile(
                      title: const Text('插件'),
                      backgroundColor: Colors.blue.shade400,
                      trailing: IconButton(
                        onPressed: () => addPlugin(),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                    // CupertinoListTile(
                    //   title: TextField(
                    //     decoration: const InputDecoration(labelText: '请输入插件名称'),
                    //     controller: widget.controller.nameController,
                    //   ),
                    // ),
                    const SizedBox(height: 10),
                    CupertinoListTile(
                      title: const Text('已安装'),
                      trailing: Text(
                          '(${widget.controller.installedPlugins.length.toString()})'),
                      onTap: () =>
                          widget.controller.isShowInstalledPluginList.toggle(),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    if (widget.controller.isShowInstalledPluginList.value)
                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.controller.pluginNames.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final name = widget.controller.pluginNames[index];
                            final versions =
                                widget.controller.getInstalledVersion(name);
                            return ExpansionTile(
                              title: Text(name),
                              children: List.generate(versions.length, (index) {
                                return Obx(() {
                                  final info =
                                      widget.controller.currentPluginInfo.value;
                                  final version = versions[index];
                                  return Obx(
                                    () => CupertinoListTile(
                                      title: Text(version.value.cli.ref),
                                      subtitle: Text(version.value.description),
                                      trailing: Icon(
                                        Icons.check_circle,
                                        color: version.value.isActive
                                            ? Colors.green.shade400
                                            : Colors.grey,
                                      ),
                                      onTap: () {
                                        return widget.controller
                                            .activePlugin(version);
                                      },
                                      backgroundColor: version.value == info
                                          ? Colors.red.shade100
                                          : null,
                                    ),
                                  );
                                });
                              }),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    CupertinoListTile(
                      title: const Text('推荐'),
                      trailing: const Text('(0)'),
                      onTap: () =>
                          widget.controller.isShowRecommendPluginList.toggle(),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    if (widget.controller.isShowRecommendPluginList.value)
                      Expanded(
                        child: ListView.separated(
                          itemCount: 0,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return CupertinoListTile(title: Text('插件$index'));
                          },
                        ),
                      ),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() {
              final info = widget.controller.currentPluginInfo.value;
              if (info == null) {
                return Container();
              } else {
                return CommandDetailView(info);
              }
            }),
          )
        ],
      ),
    );
  }

  /// 添加插件
  Future<void> addPlugin() async {
    final addPluginController = AddPluginController();
    await Get.dialog(Dialog(child: AddPluginView(addPluginController)));
    final url = addPluginController.urlController.text;
    final ref = addPluginController.refController.text;
    final isLocal = addPluginController.isLocalPlugin.value;
    final isOverwrite = addPluginController.isOverwrite.value;
    if (url.isEmpty) return;
    if (!isLocal && ref.isEmpty) return;
    widget.controller.addPlugin(url, ref, isLocal, isOverwrite);
  }

  /// 创建模板项目
  Future<void> _createPlugin() async {
    final createPluginController = CreatePluginController();
    await Get.dialog(Dialog(child: CreatePluginView(createPluginController)));
    final name = createPluginController.nameController.text;
    final url = createPluginController.urlController.text;
    final ref = createPluginController.refController.text;
    if (name.isEmpty || url.isEmpty || ref.isEmpty) return;
    widget.controller.createPlugin(
      createPluginController.nameController.text,
      createPluginController.urlController.text,
      createPluginController.refController.text,
    );
  }
}
