import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class WorkflowEvent extends Equatable {
  const WorkflowEvent();

  @override
  List<Object?> get props => [];
}

class ProjectCreated extends WorkflowEvent {
  final String title;
  const ProjectCreated({required this.title});

  @override
  List<Object?> get props => [title];
}

class ProjectSwitched extends WorkflowEvent {
  final String projectId;
  const ProjectSwitched({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ProjectDeleted extends WorkflowEvent {
  final String projectId;
  const ProjectDeleted({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class MessageSent extends WorkflowEvent {
  final String content;
  const MessageSent({required this.content});

  @override
  List<Object?> get props => [content];
}

class NodeMoved extends WorkflowEvent {
  final String projectId;
  final String nodeId;
  final Offset newPosition;

  const NodeMoved({
    required this.projectId,
    required this.nodeId,
    required this.newPosition,
  });

  @override
  List<Object?> get props => [projectId, nodeId, newPosition];
}
