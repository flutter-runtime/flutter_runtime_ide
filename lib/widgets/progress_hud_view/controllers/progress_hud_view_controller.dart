import 'dart:math';

import 'package:flutter_runtime_ide/analyzer/generate_runtime_package.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ProgressHudViewController extends GetxController {
  var progress = 0.0.obs;
  ItemScrollController scrollController = ItemScrollController();

  var logEvents = <GenerateRuntimePackageProgress>[].obs;

  void show([
    double progress = 0,
    GenerateRuntimePackageProgress? progressLog,
  ]) {
    double progress0 = min(progress, 1.0);
    progress0 = max(progress0, 0);

    this.progress.value = progress0;
  }

  updateText(GenerateRuntimePackageProgress e) {
    final index = logEvents.indexWhere((element) =>
        element.progressType == e.progressType &&
        element.packageName == e.packageName);
    if (index == -1) {
      logEvents.add(e);
      Future.delayed(Duration.zero).then((value) => scrollToIndex(index + 1));
    } else {
      logEvents.removeAt(index);
      logEvents.add(e);
    }
  }

  void reset() {
    progress.value = 0.0;
    logEvents.clear();
  }

  void scrollToIndex(int index) {
    scrollController.jumpTo(index: index);
  }

  @override
  void onClose() {
    super.onClose();
    reset();
  }
}
