class WorkType {
  final String value;
  final String label;

  WorkType({required this.value, required this.label});

  factory WorkType.fromJson(Map<String, dynamic> json) {
    return WorkType(
      value: json['value'],
      label: json['label'],
    );
  }
}
