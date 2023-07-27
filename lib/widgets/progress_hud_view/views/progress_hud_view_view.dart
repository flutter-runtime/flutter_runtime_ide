import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';

import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/progress_hud_view_controller.dart';

class ProgressHudView extends GetView<ProgressHudViewController> {
  const ProgressHudView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Row(
                children: [
                  Obx(
                    () => Text(
                      '当前进度 ${(controller.progress.value * 100).toPrecision(2)}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Obx(
                      () => LinearProgressIndicator(
                        value: controller.progress.value,
                        minHeight: 20,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  final logEvents = controller.logEvents;
                  return ScrollablePositionedList.builder(
                    itemBuilder: (context, index) {
                      if (index == -1) return Container();
                      final element = logEvents[index];

                      return ListTile(
                          title: Text(
                        element.log,
                        style: const TextStyle(color: Colors.white),
                      ));
                    },
                    // separatorBuilder: (context, index) => const Divider(),
                    itemCount: logEvents.length,
                    itemScrollController: controller.scrollController,
                  );
                }),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => hideProgressHud(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
