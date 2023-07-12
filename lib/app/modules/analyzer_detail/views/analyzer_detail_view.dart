import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_detail_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_config_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_config_view.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AnalyzerDetailView extends StatelessWidget {
  final AnalyzerDetailController controller;
  const AnalyzerDetailView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '分析${controller.packageInfo.name}(${controller.packageInfo.version})'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => fixAnalyzer(),
            icon: const Icon(Icons.auto_fix_high),
          ),
          IconButton(
            onPressed: () => controller.analyzerPackage(),
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () => controller.openFolder(),
            icon: const Icon(Icons.folder_open),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => LinearProgressIndicator(
              value: controller.progress.value,
              color: Colors.green,
              minHeight: 8,
            ),
          ),
          ListTile(
            leading: Text(
              '库名称',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '是否使用缓存',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Obx(
                  () => Switch(
                    value: controller.useCache.value,
                    onChanged: (value) =>
                        controller.changeAllCacheStates(value),
                  ),
                )
              ],
            ),
            tileColor: Colors.blue.shade300,
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ScrollablePositionedList.separated(
              itemScrollController: controller.itemScrollController,
              itemCount: controller.allDependenceInfos.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final item = controller.allDependenceInfos[index];
                return Obx(() => SwitchListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Obx(
                              () => CircularProgressIndicator(
                                value: controller.getItemProgress(item.name),
                                color: Colors.blue.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text('${item.name}(${item.version})'),
                        ],
                      ),
                      value: controller.getCacheStates(item.name).value,
                      onChanged: (value) =>
                          controller.changeCacheStates(item.name, value),
                    ));
              },
            ),
          ),
          ListTile(
            leading: Text(
              '日志',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.clear_sharp),
              onPressed: () => controller.clearLogs(),
            ),
            tileColor: Colors.blue.shade300,
          ),
          Expanded(
            child: Obx(
              () => ListView.separated(
                controller: controller.logScrollController,
                itemCount: controller.logs.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  LogEvent event = controller.logs[index];
                  Color? logTextColor;
                  switch (event.level) {
                    case Level.debug:
                      logTextColor = Colors.black;
                      break;
                    case Level.error:
                      logTextColor = Colors.red;
                      break;
                    case Level.info:
                      logTextColor = Colors.green;
                      break;
                    case Level.warning:
                      logTextColor = Colors.yellow;
                      break;
                    case Level.nothing:
                      logTextColor = Colors.white;
                      break;
                    case Level.wtf:
                      logTextColor = Colors.orange;
                      break;
                    case Level.verbose:
                      logTextColor = Colors.grey.shade500;
                      break;
                    default:
                  }
                  return ListTile(
                    title: Text(
                      event.message.toString(),
                      style: TextStyle(color: logTextColor),
                    ),
                    subtitle: Text(
                      event.time.toString(),
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 修复分析的结果
  fixAnalyzer() async {
    final result = await Get.defaultDialog<bool>(
      title: '警告!',
      middleText: '需要提前使用缓存进行分析工程，是否继续?',
      onConfirm: () => Get.back(result: true),
      onCancel: () {},
    );
    if (!JSON(result).boolValue) return;
    Get.dialog(FixConfigView(FixConfigController(controller.packageInfo)));
  }
}