import 'package:flutter/material.dart';
import 'sdui_node.dart';
import 'sdui_registry.dart';

class SduiParserWidget extends StatelessWidget {
  const SduiParserWidget({super.key, required this.node});

  final SduiNode node;

  @override
  Widget build(BuildContext context) {
    return SduiRegistry.instance.buildNode(context, node);
  }
}
