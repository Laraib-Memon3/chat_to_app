class EdgeModel {
  final String source;
  final String target;
  final String? label;

  const EdgeModel({required this.source, required this.target, this.label});

  factory EdgeModel.fromJson(Map<String, dynamic> json) {
    return EdgeModel(
      source: json['source'] as String,
      target: json['target'] as String,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'source': source, 'target': target, 'label': label};
  }
}
