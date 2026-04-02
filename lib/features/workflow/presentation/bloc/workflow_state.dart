import 'package:equatable/equatable.dart';
import '../../domain/entities/workflow_project.dart';

enum WorkflowStatus { initial, loading, success, error }

class WorkflowState extends Equatable {
  final Map<String, WorkflowProject> projects;
  final String? activeProjectId;
  final WorkflowStatus status;
  final String? errorMessage;

  const WorkflowState({
    this.projects = const {},
    this.activeProjectId,
    this.status = WorkflowStatus.initial,
    this.errorMessage,
  });

  factory WorkflowState.initial() => const WorkflowState();

  WorkflowState copyWith({
    Map<String, WorkflowProject>? projects,
    String? activeProjectId,
    WorkflowStatus? status,
    String? errorMessage,
  }) {
    return WorkflowState(
      projects: projects ?? this.projects,
      activeProjectId: activeProjectId ?? this.activeProjectId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [projects, activeProjectId, status, errorMessage];
}
