import 'package:equatable/equatable.dart';
import 'diagram_node.dart';
import 'diagram_edge.dart';

class GraphDiff extends Equatable {
  final List<DiagramNode> newNodes;
  final List<DiagramEdge> newEdges;
  final List<String> deletedNodes;
  final List<String> deletedEdges;
  final List<DiagramNode> updatedNodes;
  final String? explanation;

  const GraphDiff({
    this.newNodes = const [],
    this.newEdges = const [],
    this.deletedNodes = const [],
    this.deletedEdges = const [],
    this.updatedNodes = const [],
    this.explanation,
  });

  @override
  List<Object?> get props => [
    newNodes,
    newEdges,
    deletedNodes,
    deletedEdges,
    updatedNodes,
    explanation,
  ];
}
