import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class FixSelectController<T> extends GetxController {
  List<FixSelectItem<T>> items;
  final bool allowDelete;
  final TextEditingController nameController = TextEditingController();

  var displayItems = <FixSelectItem<T>>[].obs;

  FixSelectController(this.items, {this.allowDelete = true}) {
    displayItems.value = items;

    nameController.addListener(() {
      if (nameController.text.isEmpty) {
        displayItems.value = items;
        return;
      }
      displayItems.value = extractAllSorted(
        query: nameController.text,
        choices: items,
        cutoff: 30,
        getter: (obj) => obj.name,
      ).map((e) => e.choice).toList();
    });
  }

  void updateItems(List<FixSelectItem<T>> items) {
    this.items = items;
    displayItems.value = items;
  }

  void remove(FixSelectItem<T> item) {
    final items0 = [...items];
    items0.remove(item);
    updateItems(items0);
  }
}

class FixSelectItem<T> {
  final T item;
  final String name;
  const FixSelectItem(this.item, this.name);
}
