import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_runtime_ide/widgets/run_command/run_conmand_controller.dart';
import 'package:get/get.dart';

class RunCommandView extends StatelessWidget {
  final RunCommandController controller;
  const RunCommandView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('运行命令'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final command = controller.currentCommand.value;
          return Column(
            children: [
              if (command != null)
                CupertinoListTile(
                  title: Text('${command.command} ${command.commandArg}'),
                  backgroundColor: Colors.blue.shade100,
                ),
              Expanded(
                  child: ListView.separated(
                itemCount: controller.logs.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  return CupertinoListTile(
                      title: Text(controller.logs[index].message));
                },
              ))
            ],
          );
        }),
      ),
    );
  }
}
