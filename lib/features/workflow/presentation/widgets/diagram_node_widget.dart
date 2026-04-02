import 'package:flutter/material.dart';
import '../../domain/entities/diagram_node.dart';
import 'shape_painter.dart';

class DiagramNodeWidget extends StatelessWidget {
  final DiagramNode node;
  final bool isSelected;
  final VoidCallback? onTap;

  const DiagramNodeWidget({
    super.key,
    required this.node,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 80),
            painter: ShapePainter(
              shape: node.shape,
              color: Theme.of(context).colorScheme.surface,
              borderColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              node.label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
