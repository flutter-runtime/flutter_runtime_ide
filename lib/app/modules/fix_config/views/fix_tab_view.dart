import 'package:flutter/material.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/controllers/fix_select_controller.dart';
import 'package:flutter_runtime_ide/app/modules/fix_config/views/fix_select_view.dart';
import 'package:get/get.dart';

class FixTabView extends StatefulWidget {
  final FixTabViewController controller;
  const FixTabView(this.controller, {super.key});

  @override
  State<FixTabView> createState() => _FixTabViewState();
}

class _FixTabViewState extends State<FixTabView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.tabController =
        TabController(length: widget.controller.items.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: widget.controller.tabController,
          tabs: widget.controller.items.map((e) {
            return Tab(
              child: Text(
                e.tabName,
                style: TextStyle(color: Colors.blue.shade300),
              ),
            );
          }).toList(),
        ),
        const Divider(),
        Expanded(
          child: TabBarView(
            controller: widget.controller.tabController,
            children: widget.controller.items.map(
              (e) {
                return FixSelectView(
                  controller: e.selectController,
                  onTap: e.onTap,
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class FixTabViewSource<T extends FixSelectItem> {
  final String tabName;
  final FixSelectController<T> selectController;
  final void Function(T? item)? onTap;
  FixTabViewSource(this.tabName, this.selectController, {this.onTap});
}

class FixTabViewController extends GetxController {
  final List<FixTabViewSource> items;
  late TabController tabController;
  FixTabViewController(this.items);
}
