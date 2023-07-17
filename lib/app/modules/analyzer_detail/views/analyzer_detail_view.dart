import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_detail_controller.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_info_controller.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/views/analyzer_info_view.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_config_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_config_view.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../analyzer/analyze_info.dart';

class AnalyzerDetailView extends StatefulWidget {
  final AnalyzerDetailController controller;
  const AnalyzerDetailView(this.controller, {Key? key}) : super(key: key);

  @override
  State<AnalyzerDetailView> createState() => _AnalyzerDetailViewState();
}

class _AnalyzerDetailViewState extends State<AnalyzerDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '分析${widget.controller.packageInfo.name}(${widget.controller.packageInfo.version})'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => fixAnalyzer(),
            icon: const Icon(Icons.auto_fix_high),
          ),
          IconButton(
            onPressed: () => widget.controller.analyzerPackage(),
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () => widget.controller.openFolder(),
            icon: const Icon(Icons.folder_open),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => LinearProgressIndicator(
              value: widget.controller.progress.value,
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
                    value: widget.controller.useCache.value,
                    onChanged: (value) =>
                        widget.controller.changeAllCacheStates(value),
                  ),
                )
              ],
            ),
            tileColor: Colors.blue.shade300,
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ScrollablePositionedList.separated(
              itemScrollController: widget.controller.itemScrollController,
              itemCount: widget.controller.allDependenceInfos.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final item = widget.controller.allDependenceInfos[index];
                return Obx(() => SwitchListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Obx(
                              () => CircularProgressIndicator(
                                value: widget.controller
                                    .getItemProgress(item.name),
                                color: Colors.blue.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text('${item.name}(${item.version})'),
                        ],
                      ),
                      value: widget.controller.getCacheStates(item.name).value,
                      onChanged: (value) =>
                          widget.controller.changeCacheStates(item.name, value),
                    ));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade300,
            child: Row(
              children: [
                Text(
                  '日志',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.clear_sharp),
                  onPressed: () => widget.controller.clearLogs(),
                ),
                _logLevelTabbar(context),
                const Spacer(),
                Text(
                  '分析信息:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () =>
                      _showAnalyzerInfoView(widget.controller.errorInfos),
                  icon: const Icon(Icons.error_outline),
                  label: Obx(
                    () => Text(widget.controller.errorInfos.length.toString()),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.yellow,
                  ),
                  onPressed: () =>
                      _showAnalyzerInfoView(widget.controller.warningInfos),
                  icon: const Icon(Icons.warning),
                  label: Obx(
                    () =>
                        Text(widget.controller.warningInfos.length.toString()),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () =>
                      _showAnalyzerInfoView(widget.controller.infoInfos),
                  icon: const Icon(Icons.info),
                  label: Obx(
                    () => Text(widget.controller.infoInfos.length.toString()),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.separated(
                controller: widget.controller.logScrollController,
                itemCount: widget.controller.logs.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  LogEvent event = widget.controller.logs[index];
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

  Widget _logLevelTabbar(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(foregroundColor: Colors.grey.shade400),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.black),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.green),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.yellow),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.orange),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(foregroundColor: Colors.grey.shade300),
          onPressed: () {},
          icon: const Icon(Icons.circle),
          label: Obx(
            () => Text(widget.controller.errorInfos.length.toString()),
          ),
        ),
      ],
    );
  }

  _showAnalyzerInfoView(List<AnalyzeInfo> infos) async {
    Get.bottomSheet(AnalyzerInfoView(
      AnalyzerInfoController(widget.controller.packageInfo, infos),
    ));
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
    Get.dialog(
        FixConfigView(FixConfigController(widget.controller.packageInfo)));
  }
}
