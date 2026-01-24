
class SpecializationItem {
  final int id;
  final String name;

  SpecializationItem({required this.id, required this.name});

  factory SpecializationItem.fromJson(Map<String, dynamic> json) =>
      SpecializationItem(
        id: json["id"],
        name: json["name"],
      );
}

