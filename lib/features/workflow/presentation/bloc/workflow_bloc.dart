import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/edge_model.dart';
import '../../data/models/node_model.dart';
import '../../domain/entities/diagram_edge.dart';
import '../../domain/entities/diagram_node.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/workflow_project.dart';
import '../../domain/usecases/process_user_prompt.dart';
import '../../domain/usecases/update_node_position.dart';
import 'workflow_event.dart';
import 'workflow_state.dart';

class WorkflowBloc extends HydratedBloc<WorkflowEvent, WorkflowState> {
  final ProcessUserPrompt processUserPrompt;
  final UpdateNodePosition updateNodePosition;
  final _uuid = const Uuid();

  WorkflowBloc({
    required this.processUserPrompt,
    required this.updateNodePosition,
  }) : super(WorkflowState.initial()) {
    on<ProjectCreated>(_onProjectCreated);
    on<ProjectSwitched>(_onProjectSwitched);
    on<ProjectDeleted>(_onProjectDeleted);
    on<MessageSent>(_onMessageSent);
    on<NodeMoved>(_onNodeMoved);
  }

  void _onProjectCreated(ProjectCreated event, Emitter<WorkflowState> emit) {
    final id = _uuid.v4();
    final newProject = WorkflowProject(
      id: id,
      title: event.title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updatedProjects = Map<String, WorkflowProject>.from(state.projects);
    updatedProjects[id] = newProject;

    emit(state.copyWith(projects: updatedProjects, activeProjectId: id));
  }

  void _onProjectSwitched(ProjectSwitched event, Emitter<WorkflowState> emit) {
    emit(state.copyWith(activeProjectId: event.projectId));
  }

  void _onProjectDeleted(ProjectDeleted event, Emitter<WorkflowState> emit) {
    final updatedProjects = Map<String, WorkflowProject>.from(state.projects);
    updatedProjects.remove(event.projectId);

    emit(
      state.copyWith(
        projects: updatedProjects,
        activeProjectId: state.activeProjectId == event.projectId
            ? null
            : state.activeProjectId,
      ),
    );
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<WorkflowState> emit,
  ) async {
    final projectId = state.activeProjectId;
    if (projectId == null) return;

    final currentProject = state.projects[projectId]!;
    final userMessage = Message(
      id: _uuid.v4(),
      content: event.content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final updatedProjectWithUserMsg = currentProject.copyWith(
      messages: [...currentProject.messages, userMessage],
      updatedAt: DateTime.now(),
    );

    final projectsWithUserMsg = Map<String, WorkflowProject>.from(
      state.projects,
    );
    projectsWithUserMsg[projectId] = updatedProjectWithUserMsg;

    emit(
      state.copyWith(
        projects: projectsWithUserMsg,
        status: WorkflowStatus.loading,
      ),
    );

    try {
      final diff = await processUserPrompt(
        event.content,
        updatedProjectWithUserMsg,
      );

      final assistantMessage = Message(
        id: _uuid.v4(),
        content: diff.explanation ?? 'I have updated the diagram based on your request.',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final updatedNodes = List<DiagramNode>.from(
        updatedProjectWithUserMsg.nodes,
      );
      final updatedEdges = List<DiagramEdge>.from(
        updatedProjectWithUserMsg.edges,
      );

      // Handle Deleted Nodes
      for (final id in diff.deletedNodes) {
        updatedNodes.removeWhere((n) => n.id == id);
        updatedEdges.removeWhere((e) => e.source == id || e.target == id);
      }

      // Handle Deleted Edges
      for (final id in diff.deletedEdges) {
        // Try to find by ID if it's a UUID, otherwise try splitting on hyphen for source-target
        final parts = id.split('-');
        if (parts.length == 2) {
          updatedEdges.removeWhere(
            (e) => e.source == parts[0] && e.target == parts[1],
          );
        }
      }

      // Handle New Nodes
      updatedNodes.addAll(diff.newNodes);

      // Handle New Edges
      updatedEdges.addAll(diff.newEdges);

      // Handle Updated Nodes
      for (final updatedNode in diff.updatedNodes) {
        final index = updatedNodes.indexWhere(
          (node) => node.id == updatedNode.id,
        );
        if (index != -1) {
          updatedNodes[index] = updatedNode;
        }
      }

      final finalizedProject = updatedProjectWithUserMsg.copyWith(
        messages: [...updatedProjectWithUserMsg.messages, assistantMessage],
        nodes: updatedNodes,
        edges: updatedEdges,
        updatedAt: DateTime.now(),
      );

      final finalProjects = Map<String, WorkflowProject>.from(state.projects);
      finalProjects[projectId] = finalizedProject;

      emit(
        state.copyWith(projects: finalProjects, status: WorkflowStatus.success),
      );
    } catch (e, stack) {
      developer.log(
        'Error applying diagram update',
        name: 'workflow.bloc',
        error: e,
        stackTrace: stack,
      );
      final errorMessage = e.toString();
      final assistantErrorMessage = Message(
        id: _uuid.v4(),
        content: 'Sorry, I encountered an error: $errorMessage',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      final errorProject = updatedProjectWithUserMsg.copyWith(
        messages: [
          ...updatedProjectWithUserMsg.messages,
          assistantErrorMessage,
        ],
        updatedAt: DateTime.now(),
      );

      final errorProjects = Map<String, WorkflowProject>.from(state.projects);
      errorProjects[projectId] = errorProject;

      emit(
        state.copyWith(
          projects: errorProjects,
          status: WorkflowStatus.error,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  void _onNodeMoved(NodeMoved event, Emitter<WorkflowState> emit) {
    final project = state.projects[event.projectId];
    if (project == null) return;

    final updatedProject = updateNodePosition(
      project,
      event.nodeId,
      event.newPosition,
    );

    final updatedProjects = Map<String, WorkflowProject>.from(state.projects);
    updatedProjects[event.projectId] = updatedProject;

    emit(state.copyWith(projects: updatedProjects));
  }

  @override
  WorkflowState? fromJson(Map<String, dynamic> json) {
    try {
      final projectsJson = json['projects'] as Map<String, dynamic>;
      final projects = projectsJson.map((key, value) {
        final projectMap = value as Map<String, dynamic>;
        final messages = (projectMap['messages'] as List).map((m) {
          final mJson = m as Map<String, dynamic>;
          return Message(
            id: mJson['id'],
            content: mJson['content'],
            role: MessageRole.values.byName(mJson['role']),
            timestamp: DateTime.parse(mJson['timestamp']),
          );
        }).toList();

        final nodes = (projectMap['nodes'] as List).map((n) {
          final nJson = n as Map<String, dynamic>;
          final model = NodeModel.fromJson(nJson);
          return DiagramNode(
            id: model.id,
            label: model.label,
            shape: model.shape,
            position: Offset(model.x, model.y),
          );
        }).toList();

        final edges = (projectMap['edges'] as List).map((e) {
          final eJson = e as Map<String, dynamic>;
          final model = EdgeModel.fromJson(eJson);
          return DiagramEdge(
            source: model.source,
            target: model.target,
            label: model.label,
          );
        }).toList();

        return MapEntry(
          key,
          WorkflowProject(
            id: projectMap['id'],
            title: projectMap['title'],
            messages: messages,
            nodes: nodes,
            edges: edges,
            createdAt: DateTime.parse(projectMap['createdAt']),
            updatedAt: DateTime.parse(projectMap['updatedAt']),
          ),
        );
      });

      return WorkflowState(
        projects: projects,
        activeProjectId: json['activeProjectId'],
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(WorkflowState state) {
    final projectsJson = state.projects.map((key, project) {
      final messages = project.messages
          .map(
            (m) => {
              'id': m.id,
              'content': m.content,
              'role': m.role.name,
              'timestamp': m.timestamp.toIso8601String(),
            },
          )
          .toList();

      final nodes = project.nodes
          .map(
            (n) => NodeModel(
              id: n.id,
              label: n.label,
              shape: n.shape,
              x: n.position.dx,
              y: n.position.dy,
            ).toJson(),
          )
          .toList();

      final edges = project.edges
          .map(
            (e) => EdgeModel(
              source: e.source,
              target: e.target,
              label: e.label,
            ).toJson(),
          )
          .toList();

      return MapEntry(key, {
        'id': project.id,
        'title': project.title,
        'messages': messages,
        'nodes': nodes,
        'edges': edges,
        'createdAt': project.createdAt.toIso8601String(),
        'updatedAt': project.updatedAt.toIso8601String(),
      });
    });

    return {'projects': projectsJson, 'activeProjectId': state.activeProjectId};
  }
}
