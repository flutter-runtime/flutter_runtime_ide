import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/data/package_config.dart';
import 'package:get/get.dart';
import '../../fix_config/controllers/fix_runtime_config_controller.dart';
import '../../fix_config/views/fix_runtime_config_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => controller.analyzerAllPackageCode(),
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () {
              final controller = FixRuntimeConfigController();
              Get.dialog(
                Dialog(
                  child: FixRuntimeConfigView(controller: controller),
                ),
                barrierDismissible: false,
              );
            },
            icon: const Icon(Icons.bug_report),
          )
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.blue.shade100,
              child: Column(
                children: [
                  _titleValueWidget("工程路径", controller.progectPath.value),
                  if (controller.packageConfig.value == null)
                    Container()
                  else
                    Column(
                      children: [
                        _titleValueWidget(
                          "configVersion",
                          controller.packageConfig.value!.configVersion
                              .toString(),
                        ),
                        _titleValueWidget(
                          "generated",
                          controller.packageConfig.value!.generated,
                        ),
                        _titleValueWidget(
                          "generator",
                          controller.packageConfig.value!.generator,
                        ),
                        _titleValueWidget(
                          "generatorVersion",
                          controller.packageConfig.value!.generatorVersion,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            CupertinoTextField(
              placeholder: "输入关键词过滤",
              controller: controller.searchController,
              onChanged: (value) {
                controller.search();
              },
            ),
            Obx(() {
              final packages = controller.displayPackages;
              return Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    PackageInfo packageInfo = packages[index];
                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              _titleValueWidget("name", packageInfo.name),
                              _titleValueWidget("rootUri", packageInfo.rootUri),
                              _titleValueWidget(
                                  "packageUri", packageInfo.packageUri),
                              _titleValueWidget("languageVersion",
                                  packageInfo.languageVersion),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          right: 20,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                controller
                                    .analyzerPackageCode(packageInfo.name);
                              },
                              icon: const Icon(Icons.analytics),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: packages.length,
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _titleValueWidget(String title, String value) {
    return Row(children: [
      SizedBox(
        width: 150,
        child: Text(
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(color: Colors.grey.shade600)),
        ),
      ),
    ]);
  }
}
