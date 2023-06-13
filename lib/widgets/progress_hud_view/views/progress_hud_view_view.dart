import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import '../controllers/progress_hud_view_controller.dart';

class ProgressHudView extends GetView<ProgressHudViewController> {
  const ProgressHudView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 100),
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          // color: Colors.white.withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 20.0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Obx(() => LiquidLinearProgressIndicator(
                      value: controller.progress.value,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      borderRadius: 10.0,
                      center: Text(
                        "${(controller.progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 15),
              Obx(
                () => Text(
                  controller.text.value,
                  style: TextStyle(color: Colors.blue.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
