import 'package:equatable/equatable.dart';

class DiagramEdge extends Equatable {
  final String source;
  final String target;
  final String? label;

  const DiagramEdge({required this.source, required this.target, this.label});

  @override
  List<Object?> get props => [source, target, label];
}
