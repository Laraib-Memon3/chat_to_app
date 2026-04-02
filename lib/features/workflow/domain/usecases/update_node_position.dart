import 'package:flutter/material.dart';
import '../entities/workflow_project.dart';

class UpdateNodePosition {
  WorkflowProject call(
    WorkflowProject project,
    String nodeId,
    Offset newPosition,
  ) {
    final nodes = project.nodes.map((node) {
      if (node.id == nodeId) {
        return node.copyWith(position: newPosition);
      }
      return node;
    }).toList();

    return project.copyWith(nodes: nodes, updatedAt: DateTime.now());
  }
}
