import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class FixSelectController<T extends FixSelectItem> extends GetxController {
  late List<T> items;
  final bool allowDelete;
  final TextEditingController nameController = TextEditingController();

  var displayItems = <T>[].obs;
  FixSelectController(this.items, {this.allowDelete = true}) {
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
    displayItems.value = extractAllSorted(
      query: nameController.text,
      choices: items,
      cutoff: 60,
      getter: (obj) => obj.name,
    ).map((e) => e.choice).toList();
  }

  void remove(T item) {
    final items0 = [...items];
    items0.remove(item);
    updateItems(items0);
  }

  void add(T item) {
    final items0 = [...items];
    items0.add(item);
    updateItems(items0);
  }
}

abstract class FixSelectItem {
  String get name;
}
