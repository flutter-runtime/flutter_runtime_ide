import 'dart:ui';

import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:flutter_runtime_ide/widgets/progress_hud_view/views/progress_hud_view_view.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../widgets/progress_hud_view/controllers/progress_hud_view_controller.dart';

Future<void> showProgressHud() async {
  ProgressHudViewController controller = Get.find<ProgressHudViewController>();
  controller.reset();
  if (!JSON(Get.isDialogOpen).boolValue) {
    Get.dialog(const ProgressHudView());
    await Future.delayed(Get.defaultDialogTransitionDuration);
  }
}

updateProgressHud({double progress = 0.0}) {
  ProgressHudViewController controller = Get.find<ProgressHudViewController>();
  controller.show(progress);
}

void hideProgressHud() {
  if (JSON(Get.isDialogOpen).boolValue) {
    Get.back();
  }
}

void showHUD() {
  Get.dialog(const HUDView(), barrierDismissible: false);
}

void hideHUD() {
  Get.back();
}

class HUDView extends StatelessWidget {
  const HUDView({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: LoadingIndicator(
            indicatorType: Indicator.lineScaleParty,
            strokeWidth: 10,
          ),
        ),
      ),
    );
  }
}
