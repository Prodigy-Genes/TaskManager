class Task {
  final String id; // The ID will be provided by the backend API when the task is created
  final String name;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    DateTime? createdAt,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Method to create a Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    // Check if 'data' field exists
    final data = json['data'] ?? json; // Fallback to json if 'data' is not present
    return Task(
      id: data['id'].toString(), // Convert the id to String
      name: data['title'], // Use 'title'
      description: data['description'], // Use 'description'
      dueDate: DateTime.tryParse(data['dueDate'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(), // Parse dueDate if available
      createdAt: DateTime.now(), // Assuming this is the current time when created
      isCompleted: data['isCompleted'] ?? false, // Use provided isCompleted value
    );
  }

  // Method to convert a Task to JSON (used when sending data to the API)
  Map<String, dynamic> toJson() {
  return {
    'title': name, 
    'description': description,
  };
}

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
