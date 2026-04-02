import '../entities/workflow_project.dart';
import '../entities/graph_diff.dart';

abstract class WorkflowRepository {
  Future<GraphDiff> processPrompt(
    String prompt,
    WorkflowProject currentProject,
  );
}
