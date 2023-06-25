import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:flutter_runtime_ide/widgets/progress_hud_view/views/progress_hud_view_view.dart';
import 'package:get/get.dart';

import '../../widgets/progress_hud_view/controllers/progress_hud_view_controller.dart';

void showProgressHud({
  double progress = 0.0,
  String? text,
}) {
  logger.d("progress: $progress, text: $text");
  ProgressHudViewController controller = Get.find<ProgressHudViewController>();
  if (text != null) {
    controller.text(text);
  }
  controller.progress(progress);
  if (!JSON(Get.isDialogOpen).boolValue) {
    Get.dialog(const ProgressHudView());
  }

  if (progress >= 1) {
    Future.delayed(const Duration(milliseconds: 500)).then(
      (value) => hideProgressHud(),
    );
  }
}

void hideProgressHud() {
  if (JSON(Get.isDialogOpen).boolValue) {
    Get.back();
  }
}
