// Simple Task Model representing a single daily task
class Task {
  String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.isCompleted = false,
  });

  // Convert a Task object into a Map (JSON) to save in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Create a Task object from a Map (JSON) loaded from SharedPreferences
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      date: DateTime.parse(json['date'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }
}
