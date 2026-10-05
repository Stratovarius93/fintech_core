import 'package:equatable/equatable.dart';
import 'package:fintech_core/core/network/json_map.dart';

class SduiNode extends Equatable {
  const SduiNode({
    required this.type,
    required this.properties,
    required this.children,
  });

  final String type;
  final Map<String, dynamic> properties;
  final List<SduiNode> children;

  factory SduiNode.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SduiNode(type: 'unknown', properties: {}, children: []);
    }
    final jsonMap = JsonMap(json);
    
    return SduiNode(
      type: jsonMap.mapToStringOrNull(['type']) ?? 'unknown',
      properties: jsonMap.mapToMap(['properties']),
      children: jsonMap.mapToList<SduiNode>(
        ['children'],
        (item) => SduiNode.fromJson(item as Map<String, dynamic>?),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'properties': properties,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [type, properties, children];
}
