import 'package:darty_json_safe/darty_json_safe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';

import 'package:get/get.dart';

class FixSelectView<T extends FixSelectItem> extends StatelessWidget {
  final FixSelectController<T> controller;
  final void Function(T? item)? onTap;
  const FixSelectView({Key? key, required this.controller, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: '输入名字过滤',
          ),
          controller: controller.nameController,
        ),
        Expanded(
          child: Obx(() {
            final items = controller.displayItems;
            return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(items[index].name),
                  trailing: controller.allowDelete
                      ? IconButton(
                          onPressed: () => _onDelete(items[index]),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                  onTap: () => onTap?.call(
                    items[index],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: items.length,
            );
          }),
        )
      ],
    );
  }

  Future<void> _onDelete(T item) async {
    final result = await Get.defaultDialog<bool>(
      title: '提示!',
      middleText: '确定要删除吗?',
      onConfirm: () => Get.back(result: true),
      onCancel: () {},
    );
    if (!JSON(result).boolValue) return;
    controller.remove(item);
  }
}
