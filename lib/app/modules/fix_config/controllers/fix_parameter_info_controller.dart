import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FixParameterInfoController extends GetxController {
  final TextEditingController typeController = TextEditingController();

  FixParameterInfoController([String? type]) {
    typeController.text = type ?? '';
  }
}
