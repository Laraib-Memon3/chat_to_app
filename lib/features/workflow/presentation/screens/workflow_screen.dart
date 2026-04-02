import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message.dart';
import '../bloc/workflow_bloc.dart';
import '../bloc/workflow_event.dart';
import '../bloc/workflow_state.dart';
import '../widgets/diagram_canvas.dart';

class WorkflowScreen extends StatelessWidget {
  const WorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const _Sidebar(),
          ),
          // Chat & Canvas
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Chat Panel
                      Container(
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: _ChatPanel(),
                      ),
                      // Canvas Panel
                      Expanded(child: _CanvasPanel()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkflowBloc, WorkflowState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<WorkflowBloc>().add(
                    const ProjectCreated(title: 'New Project'),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Project'),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects.values.elementAt(index);
                  final isSelected = project.id == state.activeProjectId;
                  return ListTile(
                    title: Text(project.title),
                    selected: isSelected,
                    onTap: () {
                      context.read<WorkflowBloc>().add(
                        ProjectSwitched(projectId: project.id),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        context.read<WorkflowBloc>().add(
                          ProjectDeleted(projectId: project.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  _ChatPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkflowBloc, WorkflowState>(
      builder: (context, state) {
        final projectId = state.activeProjectId;
        if (projectId == null) {
          return const Center(child: Text('Select or create a project'));
        }

        final project = state.projects[projectId]!;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: project.messages.length,
                itemBuilder: (context, index) {
                  final message = project.messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            if (state.status == WorkflowStatus.loading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Describe your workflow...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<WorkflowBloc>().add(
                            MessageSent(content: value),
                          );
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        context.read<WorkflowBloc>().add(
                          MessageSent(content: _controller.text),
                        );
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role.name == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.content),
      ),
    );
  }
}

class _CanvasPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkflowBloc, WorkflowState>(
      builder: (context, state) {
        final projectId = state.activeProjectId;
        if (projectId == null) {
          return const Center(child: Text('Start by creating a workflow'));
        }

        final project = state.projects[projectId]!;

        return DiagramCanvas(
          project: project,
          onNodeMoved: (nodeId, pos) {
            context.read<WorkflowBloc>().add(
              NodeMoved(projectId: projectId, nodeId: nodeId, newPosition: pos),
            );
          },
        );
      },
    );
  }
}
