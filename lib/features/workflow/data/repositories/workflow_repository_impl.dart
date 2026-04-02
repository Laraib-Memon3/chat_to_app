import 'package:flutter/material.dart';
import '../../domain/entities/diagram_edge.dart';
import '../../domain/entities/diagram_node.dart';
import '../../domain/entities/graph_diff.dart';
import '../../domain/entities/workflow_project.dart';
import '../../domain/repositories/workflow_repository.dart';
import '../datasources/open_router_service.dart';
import '../models/graph_diff_model.dart';

class WorkflowRepositoryImpl implements WorkflowRepository {
  final OpenRouterServiceClient openRouterService;

  WorkflowRepositoryImpl({required this.openRouterService});

  @override
  Future<GraphDiff> processPrompt(
    String prompt,
    WorkflowProject currentProject,
  ) async {
    final model = await openRouterService.getGraphMutation(
      prompt,
      currentProject,
    );
    return _mapModelToEntity(model);
  }

  GraphDiff _mapModelToEntity(GraphDiffModel model) {
    return GraphDiff(
      newNodes: model.newNodes
          .map(
            (n) => DiagramNode(
              id: n.id,
              label: n.label,
              shape: n.shape,
              position: Offset(n.x, n.y),
            ),
          )
          .toList(),
      newEdges: model.newEdges
          .map(
            (e) =>
                DiagramEdge(source: e.source, target: e.target, label: e.label),
          )
          .toList(),
      deletedNodes: model.deletedNodes,
      deletedEdges: model.deletedEdges,
      updatedNodes: model.updatedNodes
          .map(
            (n) => DiagramNode(
              id: n.id,
              label: n.label,
              shape: n.shape,
              position: Offset(n.x, n.y),
            ),
          )
          .toList(),
      explanation: model.explanation,
    );
  }
}
