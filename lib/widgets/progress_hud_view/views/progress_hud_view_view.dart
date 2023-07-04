import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/utils/progress_hud_util.dart';

import 'package:get/get.dart';
import 'package:logger/logger.dart';
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
                      LogEvent event = logEvents[index];
                      Color? logTextColor;
                      switch (event.level) {
                        case Level.debug:
                          logTextColor = Colors.black;
                          break;
                        case Level.error:
                          logTextColor = Colors.red;
                          break;
                        case Level.info:
                          logTextColor = Colors.green;
                          break;
                        case Level.warning:
                          logTextColor = Colors.yellow;
                          break;
                        case Level.nothing:
                          logTextColor = Colors.white;
                          break;
                        case Level.wtf:
                          logTextColor = Colors.orange;
                          break;
                        case Level.verbose:
                          logTextColor = Colors.grey.shade400;
                          break;
                        default:
                      }
                      return ListTile(
                        title: Text(
                          event.message.toString(),
                          style: TextStyle(color: logTextColor),
                        ),
                        subtitle: Text(
                          event.time.toString(),
                          style: TextStyle(color: Colors.grey.shade200),
                        ),
                      );
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
