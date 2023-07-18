import 'dart:math';

import 'package:flutter_runtime_ide/common/common_function.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ProgressHudViewController extends GetxController {
  var progress = 0.0.obs;
  ItemScrollController scrollController = ItemScrollController();
  LogCallback? _logCallback;

  var logEvents = <LogEvent>[].obs;

  void show([double progress = 0]) {
    if (progress > 1) {
      logger.e(progress);
    }
    double progress0 = min(progress, 1.0);
    progress0 = max(progress0, 0);

    this.progress.value = progress0;
    if (_logCallback == null) {
      _logCallback = (event) {
        logEvents.add(event);
      };
      Logger.addLogListener(_logCallback!);
    }
  }

  void reset() {
    if (_logCallback != null) {
      Logger.removeLogListener(_logCallback!);
      _logCallback = null;
    }
    progress.value = 0.0;
    logEvents.clear();
  }

  void scrollToIndex(int index) {
    // index = min(index, logEvents.length - 1);
    scrollController.jumpTo(index: index);
  }

  @override
  void onClose() {
    super.onClose();
    reset();
  }
}
