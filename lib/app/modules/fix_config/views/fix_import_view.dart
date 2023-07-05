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
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _addShowValue();
              } else if (_tabController.index == 1) {
                _addHideValue();
              }
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    'show',
                    style: TextStyle(color: Colors.blue.shade300),
                  ),
                ),
                Tab(
                  child: Text(
                    'hide',
                    style: TextStyle(color: Colors.blue.shade300),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FixSelectView(
                    controller: widget.controller.selectShowController,
                  ),
                  FixSelectView(
                    controller: widget.controller.selectHideController,
                  ),
                ],
              ),
            )
          ],
        ),
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

  _addHideValue() async {
    final value = await showAddValue('请输入要隐藏的值');
    if (value == null) return;
    widget.controller.addHideValue(value);
  }

  _addShowValue() async {
    final value = await showAddValue('请输入要显示的值');
    if (value == null) return;
    widget.controller.addShowValue(value);
  }
}
