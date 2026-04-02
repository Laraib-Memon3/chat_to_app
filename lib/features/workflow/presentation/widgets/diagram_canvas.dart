import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../domain/entities/workflow_project.dart';
import 'diagram_node_widget.dart';
import 'grid_background_painter.dart';

class DiagramCanvas extends StatefulWidget {
  final WorkflowProject project;
  final Function(String nodeId, Offset newPosition) onNodeMoved;

  const DiagramCanvas({
    super.key,
    required this.project,
    required this.onNodeMoved,
  });

  @override
  State<DiagramCanvas> createState() => _DiagramCanvasState();
}

class _DiagramCanvasState extends State<DiagramCanvas> {
  final Graph graph = Graph()..isTree = false;
  final Algorithm algorithm = FruchtermanReingoldAlgorithm(
    FruchtermanReingoldConfiguration()
      ..iterations = 200,
    renderer: ArrowEdgeRenderer(),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.project.nodes.isEmpty) {
      return const Center(child: Text('Start by describing your workflow!'));
    }

    graph.nodes.clear();
    graph.edges.clear();

    final nodeMap = <String, Node>{};

    for (final nodeEntity in widget.project.nodes) {
      final node = Node.Id(nodeEntity.id);
      nodeMap[nodeEntity.id] = node;
      graph.addNode(node);
    }

    final addedEdges = <String>{};
    for (final edgeEntity in widget.project.edges) {
      // Ignore self-loops and duplicate edges
      if (edgeEntity.source == edgeEntity.target) continue;
      
      final edgeKey = '${edgeEntity.source}_${edgeEntity.target}';
      if (addedEdges.contains(edgeKey)) continue;

      if (nodeMap.containsKey(edgeEntity.source) &&
          nodeMap.containsKey(edgeEntity.target)) {
        graph.addEdge(nodeMap[edgeEntity.source]!, nodeMap[edgeEntity.target]!);
        addedEdges.add(edgeKey);
      }
    }

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: GridBackgroundPainter(
                spacing: 40,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 2.0,
            child: GraphView(
              graph: graph,
              algorithm: algorithm,
              paint: Paint()
                ..color = Theme.of(context).colorScheme.outline
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                final nodeId = node.key!.value as String;
                final nodeEntity = widget.project.nodes.firstWhere(
                  (n) => n.id == nodeId,
                  orElse: () => widget.project.nodes.first,
                );
                return DiagramNodeWidget(node: nodeEntity);
              },
            ),
          ),
        ],
      ),
    );
  }
}
