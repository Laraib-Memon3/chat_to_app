import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'node_shape.dart';

class DiagramNode extends Equatable {
  final String id;
  final String label;
  final NodeShape shape;
  final Offset position;

  const DiagramNode({
    required this.id,
    required this.label,
    required this.shape,
    this.position = Offset.zero,
  });

  DiagramNode copyWith({
    String? id,
    String? label,
    NodeShape? shape,
    Offset? position,
  }) {
    return DiagramNode(
      id: id ?? this.id,
      label: label ?? this.label,
      shape: shape ?? this.shape,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, label, shape, position];
}
