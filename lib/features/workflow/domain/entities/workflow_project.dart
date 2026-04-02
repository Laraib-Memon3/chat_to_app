import 'package:equatable/equatable.dart';
import 'diagram_node.dart';
import 'diagram_edge.dart';
import 'message.dart';

class WorkflowProject extends Equatable {
  final String id;
  final String title;
  final List<Message> messages;
  final List<DiagramNode> nodes;
  final List<DiagramEdge> edges;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkflowProject({
    required this.id,
    required this.title,
    this.messages = const [],
    this.nodes = const [],
    this.edges = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  WorkflowProject copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    List<DiagramNode>? nodes,
    List<DiagramEdge>? edges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkflowProject(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    messages,
    nodes,
    edges,
    createdAt,
    updatedAt,
  ];
}
