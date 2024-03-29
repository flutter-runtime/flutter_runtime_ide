import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/generate_runtime_package.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_detail_controller.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_info_controller.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/views/analyzer_info_view.dart';
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
  @override
  void initState() {
    super.initState();
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
            constraints: const BoxConstraints(maxHeight: 300),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    LogEvent? event = widget.controller.currentAnalyzeLog.value;
                    if (event == null) return Container();
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        event.message,
                        maxLines: 1,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    );
                  }),
                ),
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
              () => ScrollablePositionedList.separated(
                itemScrollController: widget.controller.logScrollController,
                itemCount: widget.controller.logs.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  GenerateRuntimePackageProgress progress =
                      widget.controller.logs[index];
                  return ListTile(title: Text(progress.log));
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _showAnalyzerInfoView(List<AnalyzeInfo> infos) async {
    Get.bottomSheet(AnalyzerInfoView(
      AnalyzerInfoController(widget.controller.packageInfo, infos),
    ));
  }
}
