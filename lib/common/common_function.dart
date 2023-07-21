import 'dart:convert';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:event_bus/event_bus.dart';

String getDartPath() {
  String dartCommandPath = whichSync("dart") ?? "";
  return join(dirname(dartCommandPath), "cache", "dart-sdk");
}

Logger logger = Logger(
  printer: PrettyPrinter(),
  output: ConsoleOutput(),
);

String md5(String source) {
  return crypto.md5.convert(utf8.encode(source)).toString().toString();
}

Future<String?> showAddValue(String title) {
  return Get.dialog<String>(Dialog(child: AddValueView(title)));
}

String? libraryPath(String fullPath) {
  if (!fullPath.contains('/lib/')) return null;
  return fullPath.split('/lib/')[1];
}

class AddValueView extends StatelessWidget {
  final String title;
  const AddValueView(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: title),
            controller: textEditingController,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => Get.back(result: textEditingController.text),
            child: const Text('添加'),
          )
        ],
      ),
    );
  }
}

EventBus eventBus = EventBus();

AstNode? getAstNodeFromElement(Element element) {
  AnalysisSession? session = element.session;
  if (session == null) return null;
  final library = element.library;
  if (library is! LibraryElement) return null;
  SomeParsedLibraryResult parsedLibResult =
      session.getParsedLibraryByElement(library);
  if (parsedLibResult is! ParsedLibraryResult) return null;
  ElementDeclarationResult? elDeclarationResult =
      parsedLibResult.getElementDeclaration(element);
  return elDeclarationResult?.node;
}
