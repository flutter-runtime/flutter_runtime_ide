import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/analyzer/cache/analyzer_property_accessor_cache.dart';
import 'package:flutter_runtime_ide/analyzer/fix_runtime_configuration.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';
import '../../../../common/common_function.dart';
import '../controllers/fix_method_controller.dart';
import '../controllers/fix_parameter_controller.dart';
import 'fix_parameter_view.dart';

class FixMethodView extends StatelessWidget {
  final FixMethodController controller;
  const FixMethodView(this.controller, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复方法配置'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ListTile(
              leading: const Text('是否显示'),
              trailing: Obx(
                () => Switch(
                  value: controller.isShow.value,
                  onChanged: (isOn) {},
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: FixSelectView(
                controller: controller.selectController,
                onTap: (item) => Unwrap(item).map((e) {
                  return _showFixParameterView(e);
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showFixParameterView(AnalyzerPropertyAccessorCache cache) {
    Get.dialog(FixParameterView(FixParameterController(cache)));
  }
}
