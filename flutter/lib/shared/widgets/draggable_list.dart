import 'package:flutter/material.dart';

class DraggableList extends StatelessWidget {
  const DraggableList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ReorderCallback onReorder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(context, index),
      onReorder: onReorder,
      padding: padding,
      proxyDecorator: (child, _, __) => Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
