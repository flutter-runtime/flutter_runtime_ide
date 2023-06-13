import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/welcome/bindings/welcome_binding.dart';
import 'package:flutter_runtime_ide/app/modules/welcome/views/welcome_view.dart';
import 'package:flutter_runtime_ide/widgets/progress_hud_view/controllers/progress_hud_view_controller.dart';
import 'package:flutter_runtime_ide/widgets/progress_hud_view/views/progress_hud_view_view.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  Get.put(ProgressHudViewController());
  runApp(GetMaterialApp(
    title: "Application",
    initialRoute: AppPages.INITIAL,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
    initialBinding: WelcomeBinding(),
  ));
}
