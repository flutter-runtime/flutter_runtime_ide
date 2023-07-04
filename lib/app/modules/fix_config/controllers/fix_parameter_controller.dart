import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FixParameterController extends GetxController {
  final TextEditingController typeController = TextEditingController();

  FixParameterController([String? type]) {
    typeController.text = type ?? '';
  }
}
