/// Category data model matching the backend Category schema.
class Category {
  final int id;
  final String name;
  final String color;
  final String? icon;
  final int taskCount;

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    this.taskCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      icon: json['icon'],
      taskCount: json['task_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
    };
  }
}
