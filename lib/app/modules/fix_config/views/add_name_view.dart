import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNameView extends StatelessWidget {
  final String title;
  const AddNameView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(hintText: title),
            controller: controller,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(result: controller.text),
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }
}
