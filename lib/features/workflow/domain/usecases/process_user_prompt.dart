import '../entities/workflow_project.dart';
import '../entities/graph_diff.dart';
import '../repositories/workflow_repository.dart';

class ProcessUserPrompt {
  final WorkflowRepository repository;

  ProcessUserPrompt(this.repository);

  Future<GraphDiff> call(String prompt, WorkflowProject currentProject) {
    return repository.processPrompt(prompt, currentProject);
  }
}
