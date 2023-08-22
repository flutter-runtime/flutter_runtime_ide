import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:path/path.dart';

import '../../../../common/plugin_manager.dart';

class CommandDetailView extends GetView<PluginMarketController> {
  final CommandInfo info;
  const CommandDetailView(this.info, {super.key});

  @override
  String? get tag => 'PluginMarketView';

  @override
  Widget build(BuildContext context) {
    final functions = info.functions;
    final developerController = TextEditingController(text: info.cliPath);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 400,
          child: FutureBuilder(
            future: functions,
            builder: (context, data) {
              final list = data.data ?? [];
              return ListView.separated(
                itemCount: list.length,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  final function = list[index];
                  return CupertinoListTile(
                    title: Text(function.name),
                    backgroundColor: Colors.green.shade100,
                    onTap: () {},
                  );
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              CupertinoListTile(
                title: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => controller.uninstallPlugin(info),
                      child: const Text('卸载'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => controller.reinstallPlugin(info),
                      child: const Text('重装'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => controller.installOtherVersion(info),
                      child: const Text('安装其他版本'),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 300,
                      child: SwitchListTile(
                        value: info.isDeveloper,
                        title: const Text('开发'),
                        subtitle: const Text('打开可以直接修改插件代码运行'),
                        onChanged: (value) {
                          controller.switchDeveloper(!info.isDeveloper);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (info.isDeveloper)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoListTile(
                        title: const Text('开发的仓库地址:'),
                        trailing: Expanded(
                          child: TextField(
                            controller: developerController,
                            onSubmitted: (value) {
                              controller.switchDeveloperPath(info, value);
                            },
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        title: ElevatedButton(
                          onPressed: () => controller.rebuild(info),
                          child: const Text('重新编译脚本'),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: FutureBuilder(
                    future: loadRedemeMarkdown(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.none) {
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CupertinoActivityIndicator();
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          throw Text('${snapshot.error}');
                        } else {
                          return MarkdownWidget(data: snapshot.data ?? '');
                        }
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<String> loadRedemeMarkdown() async {
    final file = File(join(info.cli.installPath, 'README.md'));
    if (!await file.exists()) return '';
    return file.readAsString();
  }
}
