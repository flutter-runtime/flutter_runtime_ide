import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_info_controller.dart';

class AnalyzerInfoView extends StatelessWidget {
  final AnalyzerInfoController controller;
  const AnalyzerInfoView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final filePaths = controller.filePaths;
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 500),
      color: Colors.white,
      child: ListView.separated(
        itemCount: filePaths.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          final filePath = filePaths[index];
          final infos = controller.getInfo(filePath);
          return ExpandedTile(
            title: Text("$filePath(${infos.length})"),
            content: Column(
              children: List.generate(infos.length, (index) {
                final info = infos[index];
                return ListTile(
                  title: Text(info.messageContent),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => controller.openFileLine(info),
                      child: Text(
                        '${info.lint}(row: ${info.line}, column: ${info.column})',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            controller: ExpandedTileController(),
          );
        },
      ),
    );
  }
}
