import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/add_plugin_controller.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/add_plugin_view.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/views/create_plugin_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';

import 'package:get/get.dart';

import '../controllers/create_plugin_controller.dart';
import '../controllers/plugin_market_controller.dart';

class PluginMarketView extends StatefulWidget {
  const PluginMarketView({Key? key}) : super(key: key);

  @override
  State<PluginMarketView> createState() => _PluginMarketViewState();
}

class _PluginMarketViewState extends State<PluginMarketView> {
  final controller = Get.put(tag: 'PluginMarketView', PluginMarketController());

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
                    CupertinoListTile(
                      title: TextField(
                        decoration: const InputDecoration(labelText: '请输入插件名称'),
                        controller: controller.nameController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoListTile(
                      title: const Text('已安装'),
                      trailing:
                          Text(controller.installedPlugins.length.toString()),
                      onTap: () =>
                          controller.isShowInstalledPluginList.toggle(),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    if (controller.isShowInstalledPluginList.value)
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.installedPlugins.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final info = controller.installedPlugins[index];

                            return Obx(() {
                              final currentInfo =
                                  controller.currentPluginInfo.value;
                              return CupertinoListTile(
                                title:
                                    Text('${info.cli.name}(${info.cli.ref})'),
                                subtitle: Text(info.description),
                                backgroundColor:
                                    currentInfo == info ? Colors.white : null,
                                onTap: () {
                                  controller.updateInfo(info);
                                },
                              );
                            });
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    CupertinoListTile(
                      title: const Text('推荐'),
                      trailing: Text('12'),
                      onTap: () =>
                          controller.isShowRecommendPluginList.toggle(),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    if (controller.isShowRecommendPluginList.value)
                      Expanded(
                        child: ListView.separated(
                          itemCount: 100,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return CupertinoListTile(title: Text('插件${index}'));
                          },
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 添加插件
  Future<void> addPlugin() async {
    final addPluginController = AddPluginController();
    await Get.dialog(Dialog(child: AddPluginView(addPluginController)));
    controller.addPlugin(
      addPluginController.urlController.text,
      addPluginController.refController.text,
      addPluginController.isLocalPlugin.value,
      addPluginController.isOverwrite.value,
    );
  }

  /// 创建模板项目
  Future<void> _createPlugin() async {
    final createPluginController = CreatePluginController();
    await Get.dialog(Dialog(child: CreatePluginView(createPluginController)));
    controller.createPlugin(
      createPluginController.nameController.text,
      createPluginController.urlController.text,
      createPluginController.refController.text,
    );
  }
}
