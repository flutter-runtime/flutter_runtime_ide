import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FixSelectController<T extends FixSelectItem> extends GetxController {
  late List<T> items;
  final bool allowDelete;
  final TextEditingController nameController = TextEditingController();

  var displayItems = <T>[].obs;

  final VoidCallback? onDeleteCallBack;

  FixSelectController(
    this.items, {
    this.allowDelete = true,
    this.onDeleteCallBack,
  }) {
    displayItems.value = items;

    nameController.addListener(() {
      _updateDisplayItems();
    });
  }

  void updateItems(List<T> items) {
    this.items = items;
    displayItems.value = items;
  }

  void _updateDisplayItems() {
    if (nameController.text.isEmpty) {
      displayItems.value = items;
      return;
    }
    displayItems.value = filter(nameController.text);
  }

  void remove(T item) {
    final items0 = [...items];
    items0.remove(item);
    updateItems(items0);
    onDeleteCallBack?.call();
  }

  void add(T item) {
    if (isExit(item)) {
      Get.snackbar('已存在', '${item.name}已存在');
      return;
    }
    final items0 = [...items];
    items0.add(item);
    updateItems(items0);
  }

  bool isExit(T item) {
    return items.contains(item);
  }

  List<T> filter(String filterText) {
    return items.where((element) {
      String findText = filterText;
      String resultText = element.name;
      while (findText.isNotEmpty) {
        final index = resultText
            .toLowerCase()
            .indexOf(findText.substring(0, 1).toLowerCase());
        if (index == -1) return false;
        resultText = resultText.substring(index);
        findText = findText.substring(1);
      }
      return true;
    }).toList();
  }
}

abstract class FixSelectItem {
  String get name;
}
