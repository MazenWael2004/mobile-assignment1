class Task {
  int? id; 
  String title; 
  String? description; 
  String dueDate; 
  String priority; 
  int isCompleted; 
  int isFavorite;

  //constructor
  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = 0, 
    this.isFavorite=0
  });

  // Convert a Task object into a Map. 
  // We need this because sqflite only understands Maps (key-value pairs).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted,
      'isFavorite':isFavorite
    };
  }

  // Extract a Task object from a Map.
  // We need this when we fetch data back out of the SQLite database.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      priority: map['priority'],
      isCompleted: map['isCompleted'],
      isFavorite: map['isFavorite']??0
    );
  }
}