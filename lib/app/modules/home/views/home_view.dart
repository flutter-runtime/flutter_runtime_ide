import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/configs/package_config.dart';
import 'package:flutter_runtime_ide/app/modules/analyzer_detail/controllers/analyzer_detail_controller.dart';
import 'package:flutter_runtime_ide/app/modules/plugin_market/controllers/plugin_market_controller.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import '../../analyzer_detail/views/analyzer_detail_view.dart';
import '../../plugin_market/views/plugin_market_view.dart';
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
            onPressed: () => _showPluginMarketView(),
            icon: const Icon(Icons.apps),
          ),
          IconButton(
            onPressed: () => controller.analyzerAllPackageCode(),
            icon: const Icon(Icons.analytics),
          ),
          IconButton(
            onPressed: () => controller.generateGlobaleRuntimePackage(),
            icon: const Icon(Icons.download_done),
          ),
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
                              _titleValueWidget(
                                "名字(版本)",
                                '${packageInfo.name}(${packageInfo.version})',
                              ),
                              _titleValueWidget(
                                "本地路径",
                                packageInfo.packagePath,
                              ),
                              _titleValueWidget(
                                "源文件路径",
                                packageInfo.packageUri,
                              ),
                              _titleValueWidget(
                                "Dart 语言版本",
                                packageInfo.languageVersion,
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          right: 20,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _showEditCustomVersionDialog(packageInfo);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showAnalyzerDetailView(packageInfo);
                                  },
                                  icon: const Icon(Icons.analytics),
                                )
                              ],
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

  _showAnalyzerDetailView(PackageInfo packageInfo) async {
    Get.dialog(
      Dialog(
        child: AnalyzerDetailView(
          AnalyzerDetailController(
            packageInfo,
            controller.packageConfig.value!,
            controller.dependency,
            await controller.getFixPlugin(packageInfo),
          ),
        ),
      ),
    );
  }

  /// 显示插件市场界面
  _showPluginMarketView() {
    Get.dialog(
      Dialog(
        child: PluginMarketView(
          PluginMarketController(controller.progectPath.value),
        ),
      ),
    );
  }

  _showEditCustomVersionDialog(PackageInfo packageInfo) async {
    final String? version = await showAddValue('请输入版本号', packageInfo.version);
    if (version == null) {
      return;
    }
    if (packageInfo.version == version) return;
    showHUD();
    await controller.setPackageVersion(packageInfo, version);
    hideHUD();
  }
}
