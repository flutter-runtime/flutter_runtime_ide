import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:path/path.dart';

class CommandDetailView extends StatelessWidget {
  final CommandInfo info;
  const CommandDetailView(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    final functions = info.functions;
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Column(
            children: [
              ListView.separated(
                itemCount: 1,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  final function = functions[index];
                  return CupertinoListTile(
                    title: Text(function.name),
                    backgroundColor: Colors.green.shade100,
                    onTap: () {},
                  );
                },
              ),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            children: [
              CupertinoListTile(
                title: Row(
                  children: [
                    ElevatedButton(onPressed: () {}, child: const Text('卸载')),
                    const SizedBox(width: 10),
                    ElevatedButton(onPressed: () {}, child: const Text('重装')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {}, child: const Text('安装其他版本')),
                  ],
                ),
              ),
              Expanded(
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
