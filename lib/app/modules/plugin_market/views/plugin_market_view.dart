import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
                        onPressed: () {},
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
                      trailing: Text('12'),
                      onTap: () =>
                          controller.isShowInstalledPluginList.toggle(),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    if (controller.isShowInstalledPluginList.value)
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
}
