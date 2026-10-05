import 'package:flutter/material.dart';
import 'sdui_node.dart';
import 'sdui_parser.dart';

typedef SduiWidgetBuilder = Widget Function(BuildContext context, SduiNode node);

class SduiRegistry {
  SduiRegistry._internal();
  static final SduiRegistry instance = SduiRegistry._internal();

  final Map<String, SduiWidgetBuilder> _builders = {};

  /// Initializes default SDUI widgets.
  void init() {
    register('text', (context, node) {
      final text = node.properties['text']?.toString() ?? '';
      final colorHex = node.properties['color']?.toString();
      final fontWeightStr = node.properties['fontWeight']?.toString();
      
      Color? color;
      if (colorHex != null && colorHex.startsWith('#')) {
        color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
      }

      FontWeight? fontWeight;
      if (fontWeightStr == 'bold') fontWeight = FontWeight.bold;

      return Text(
        text,
        style: TextStyle(color: color, fontWeight: fontWeight),
      );
    });

    register('column', (context, node) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.children.map((child) => SduiParserWidget(node: child)).toList(),
      );
    });

    register('container', (context, node) {
      final bgColorHex = node.properties['backgroundColor']?.toString();
      final padding = double.tryParse(node.properties['padding']?.toString() ?? '0') ?? 0.0;
      
      Color? bgColor;
      if (bgColorHex != null && bgColorHex.startsWith('#')) {
        bgColor = Color(int.parse(bgColorHex.substring(1), radix: 16) + 0xFF000000);
      }

      return Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: node.children.isNotEmpty 
            ? SduiParserWidget(node: node.children.first) 
            : null,
      );
    });
  }

  void register(String type, SduiWidgetBuilder builder) {
    _builders[type] = builder;
  }

  Widget buildNode(BuildContext context, SduiNode node) {
    final builder = _builders[node.type];
    if (builder != null) {
      return builder(context, node);
    }
    // Fallback widget if type is not registered
    return const SizedBox.shrink();
  }
}
