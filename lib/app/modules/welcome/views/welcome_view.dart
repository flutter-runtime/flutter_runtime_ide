import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('欢迎页面'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton.icon(
                    onPressed: () => controller.openExitProject(),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("打开项目"),
                  ),
                )
              ],
            ),
          ),
          const VerticalDivider(color: Colors.blue),
          Expanded(
            child: Obx(
              () {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      String projectPath = controller.projectPaths[index];
                      return MouseRegion(
                        onEnter: (event) {
                          controller.currentHighlightIndex.value = index;
                        },
                        child: InkWell(
                          onTap: () {
                            controller.onClickHistoryItem(projectPath);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    projectPath,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Obx(
                                  () => controller
                                              .currentHighlightIndex.value ==
                                          index
                                      ? IconButton(
                                          onPressed: () => controller
                                              .deleteProjectPath(projectPath),
                                          icon: const Icon(Icons.delete),
                                        )
                                      : Container(),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, itemCount) => const Divider(),
                    itemCount: controller.projectPaths.length);
              },
            ),
          )
        ],
      ),
    );
  }
}
