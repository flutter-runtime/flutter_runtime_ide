import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  late String _progectPath;
  HomeController() {
    _progectPath = Get.arguments as String;
  }
}
