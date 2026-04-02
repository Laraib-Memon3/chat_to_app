import 'node_model.dart';
import 'edge_model.dart';

class GraphDiffModel {
  final List<NodeModel> newNodes;
  final List<EdgeModel> newEdges;
  final List<String> deletedNodes;
  final List<String> deletedEdges;
  final List<NodeModel> updatedNodes;
  final String? explanation;

  const GraphDiffModel({
    this.newNodes = const [],
    this.newEdges = const [],
    this.deletedNodes = const [],
    this.deletedEdges = const [],
    this.updatedNodes = const [],
    this.explanation,
  });

  factory GraphDiffModel.fromJson(Map<String, dynamic> json) {
    // LLMs often hallucinate keys, let's be flexible
    final newNodesJson = json['newNodes'] as List? ?? json['nodes'] as List? ?? [];
    final newEdgesJson = json['newEdges'] as List? ?? json['edges'] as List? ?? [];
    final deletedNodesJson = json['deletedNodes'] as List? ?? [];
    final deletedEdgesJson = json['deletedEdges'] as List? ?? [];
    final updatedNodesJson = json['updatedNodes'] as List? ?? [];
    final explanation = json['explanation'] as String?;

    String? extractId(dynamic e) {
      if (e is String) return e;
      if (e is Map) {
        return e['id']?.toString() ??
            (e['source'] != null && e['target'] != null
                ? '${e['source']}-${e['target']}'
                : null);
      }
      return null;
    }

    return GraphDiffModel(
      newNodes: newNodesJson
          .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      newEdges: newEdgesJson
          .map((e) => EdgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deletedNodes: deletedNodesJson
          .map(extractId)
          .whereType<String>()
          .toList(),
      deletedEdges: deletedEdgesJson
          .map(extractId)
          .whereType<String>()
          .toList(),
      updatedNodes: updatedNodesJson
          .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newNodes': newNodes.map((e) => e.toJson()).toList(),
      'newEdges': newEdges.map((e) => e.toJson()).toList(),
      'deletedNodes': deletedNodes,
      'deletedEdges': deletedEdges,
      'updatedNodes': updatedNodes.map((e) => e.toJson()).toList(),
      'explanation': explanation,
    };
  }
}
