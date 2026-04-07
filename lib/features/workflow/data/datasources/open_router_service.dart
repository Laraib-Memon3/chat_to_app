import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../models/graph_diff_model.dart';
import '../../domain/entities/workflow_project.dart';

class OpenRouterServiceClient {
  final Dio dio;
  final String apiKey;
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  OpenRouterServiceClient({required this.dio, required this.apiKey});

  bool _isExplanationPrompt(String prompt) {
    final text = prompt.toLowerCase();
    return text.contains('explain') ||
        text.contains('explanation') ||
        text.contains('describe') ||
        text.contains('summary') ||
        text.contains('summarize') ||
        text.contains('walk me through') ||
        text.contains('what does') ||
        text.contains('how does');
  }

  String _stripCodeFences(String content) {
    var cleaned = content.trim();
    if (cleaned.contains('```json')) {
      cleaned = cleaned.split('```json')[1].split('```')[0].trim();
    } else if (cleaned.contains('```')) {
      cleaned = cleaned.split('```')[1].split('```')[0].trim();
    }
    return cleaned;
  }

  Map<String, dynamic>? _tryDecodeJson(String content) {
    try {
      final decoded = jsonDecode(content);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  String _extractExplanation(dynamic rawContent) {
    if (rawContent is Map<String, dynamic>) {
      final explanation = rawContent['explanation'];
      if (explanation is String && explanation.trim().isNotEmpty) {
        return explanation.trim();
      }
      return jsonEncode(rawContent);
    }

    if (rawContent is String) {
      final cleaned = _stripCodeFences(rawContent);
      final decoded = _tryDecodeJson(cleaned);
      if (decoded != null) {
        final explanation = decoded['explanation'];
        if (explanation is String && explanation.trim().isNotEmpty) {
          return explanation.trim();
        }
      }
      return cleaned.trim();
    }

    return rawContent.toString().trim();
  }

  Future<GraphDiffModel> getGraphMutation(
    String prompt,
    WorkflowProject currentProject,
  ) async {
    final isExplanationPrompt = _isExplanationPrompt(prompt);
    final systemPrompt = isExplanationPrompt
        ? '''
You are a workflow diagram explainer.

Return a clear, plain-text explanation of the current diagram. Do not return JSON, code fences, or any other structured output.

Current Graph State:
Nodes: ${currentProject.nodes.map((n) => '{id: ${n.id}, label: ${n.label}, shape: ${n.shape.name}}').join(', ')}
Edges: ${currentProject.edges.map((e) => '{source: ${e.source}, target: ${e.target}, label: ${e.label}}').join(', ')}
'''
        : '''
You are a workflow diagram generator. Your goal is to parse natural language descriptions into a structured graph mutation JSON.
Supported shapes: rectangle, roundedRectangle, stadium, diamond.

CRITICAL: Return ONLY a valid JSON object. Do not include any conversational text before or after the JSON.

JSON Format:
{
  "newNodes": [{"id": "unique_id_1", "label": "Action Name", "shape": "rectangle"}],
  "newEdges": [{"source": "unique_id_1", "target": "unique_id_2", "label": "Transition Label"}],
  "deletedNodes": [],
  "deletedEdges": [],
  "updatedNodes": [],
  "explanation": "A brief explanation of the changes made or a description of the current diagram if asked to explain."
}

Current Graph State:
Nodes: ${currentProject.nodes.map((n) => '{id: ${n.id}, label: ${n.label}, shape: ${n.shape.name}}').join(', ')}
Edges: ${currentProject.edges.map((e) => '{source: ${e.source}, target: ${e.target}, label: ${e.label}}').join(', ')}

When adding nodes, generate a new unique string for the 'id'.
''';

    try {
      developer.log(
        'Sending prompt to OpenRouter...',
        name: 'workflow.service',
      );
      final response = await dio.post(
        baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'nvidia/nemotron-3-nano-30b-a3b:free',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
        },
      );

      if (response.statusCode == 200) {
        final dynamic rawContent =
            response.data['choices'][0]['message']['content'];
        developer.log(
          'Raw LLM Response: $rawContent',
          name: 'workflow.service',
        );

        if (isExplanationPrompt) {
          return GraphDiffModel(explanation: _extractExplanation(rawContent));
        }

        Map<String, dynamic> json;
        if (rawContent is Map<String, dynamic>) {
          json = rawContent;
        } else if (rawContent is String) {
          final content = _stripCodeFences(rawContent);
          final decoded = _tryDecodeJson(content);
          if (decoded == null) {
            return GraphDiffModel(explanation: _extractExplanation(rawContent));
          }
          json = decoded;
        } else {
          return GraphDiffModel(explanation: _extractExplanation(rawContent));
        }

        return GraphDiffModel.fromJson(json);
      } else {
        throw Exception(
          'Failed to connect to OpenRouter: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log('OpenRouter Error: $e', name: 'workflow.service', error: e);
      throw Exception('Error processing prompt: $e');
    }
  }
}
