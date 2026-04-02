import '../../domain/entities/node_shape.dart';

class NodeModel {
  final String id;
  final String label;
  final NodeShape shape;
  final double x;
  final double y;

  const NodeModel({
    required this.id,
    required this.label,
    required this.shape,
    this.x = 0.0,
    this.y = 0.0,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      label: json['label'] as String,
      shape: NodeShape.values.byName(json['shape'] as String),
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'label': label, 'shape': shape.name, 'x': x, 'y': y};
  }
}
