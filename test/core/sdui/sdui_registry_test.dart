import 'package:fintech_core/core/sdui/sdui_node.dart';
import 'package:fintech_core/core/sdui/sdui_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    SduiRegistry.instance.init();
  });



  Widget buildWidgetWithContext(SduiNode node) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return SduiRegistry.instance.buildNode(context, node);
          },
        ),
      ),
    );
  }

  testWidgets('renders text node correctly', (tester) async {
    final node = SduiNode(
      type: 'text',
      properties: {
        'text': 'Hello World',
        'color': '#FF0000',
        'fontWeight': 'bold',
      },
      children: const [],
    );

    await tester.pumpWidget(buildWidgetWithContext(node));

    final textFinder = find.text('Hello World');
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style?.color, const Color(0xFFFF0000));
    expect(textWidget.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('renders container node correctly', (tester) async {
    final node = SduiNode(
      type: 'container',
      properties: {
        'backgroundColor': '#00FF00',
        'padding': '16.0',
      },
      children: [
        SduiNode(
          type: 'text',
          properties: {'text': 'Inside Container'},
          children: const [],
        ),
      ],
    );

    await tester.pumpWidget(buildWidgetWithContext(node));

    expect(find.text('Inside Container'), findsOneWidget);
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('renders promo node correctly', (tester) async {
    final node = SduiNode(
      type: 'promo',
      properties: {
        'title': 'Big Promo',
        'subtitle': 'Click here',
      },
      children: const [],
    );

    await tester.pumpWidget(buildWidgetWithContext(node));

    expect(find.text('Big Promo'), findsOneWidget);
    expect(find.text('Click here'), findsOneWidget);
  });

  testWidgets('renders SizedBox.shrink for unknown node', (tester) async {
    final node = SduiNode(
      type: 'unknown_type',
      properties: {},
      children: const [],
    );

    await tester.pumpWidget(buildWidgetWithContext(node));

    expect(find.byType(SizedBox), findsOneWidget);
  });
}
