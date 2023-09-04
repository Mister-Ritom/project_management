import 'package:project_management/models/project_model.dart';

class Task {
  String recordId;
  Project project;
  DateTime todoDate;
  String taskName;
  String taskDescription;
  bool hasFinished;

  Task({
    required this.recordId,
    required this.project,
    required this.todoDate,
    required this.taskName,
    required this.taskDescription,
    required this.hasFinished,
  });

  // Convert Task object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'project': project.id,
      'todoDate': todoDate.toIso8601String(),
      'taskName': taskName,
      'taskDescription': taskDescription,
      'hasFinished': hasFinished,
    };
  }

  // Create a Task object from a JSON map
  factory Task.fromJson(Map<String, dynamic> json,String id,Project project) {
    return Task(
      recordId: id,
      project: project,
      todoDate: DateTime.parse(json['todoDate']),
      taskName: json['taskName'],
      taskDescription: json['taskDescription'],
      hasFinished: json['hasFinished'],
    );
  }
}

