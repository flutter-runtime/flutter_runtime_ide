import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_import_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:flutter_runtime_ide/common/common_function.dart';

class FixImportView extends StatefulWidget {
  final FixImportController controller;
  const FixImportView(this.controller, {Key? key}) : super(key: key);

  @override
  State<FixImportView> createState() => _FixImportViewState();
}

class _FixImportViewState extends State<FixImportView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修复导入'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(),
      ),
    );
  }

  Widget buildNameList(BuildContext context, List<String> values) {
    return ListView.separated(
      itemBuilder: (context, index) => ListTile(
        leading: Text(values[index]),
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: values.length,
    );
  }
}
