import 'package:daily_habit/features/planner/domain/entities/planner_task_entity.dart';

class PlannerTaskModel {
  final String id;
  final String title;
  final String? description;
  final String dateIso;
  final String? timeString;
  final bool isCompleted;
  final String category;

  PlannerTaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateIso,
    this.timeString,
    required this.isCompleted,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateIso': dateIso,
      'timeString': timeString,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory PlannerTaskModel.fromMap(Map<dynamic, dynamic> map) {
    return PlannerTaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dateIso: map['dateIso'] as String,
      timeString: map['timeString'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      category: map['category'] as String? ?? 'General',
    );
  }

  PlannerTaskEntity toEntity() {
    return PlannerTaskEntity(
      id: id,
      title: title,
      description: description,
      date: DateTime.parse(dateIso),
      timeString: timeString,
      isCompleted: isCompleted,
      category: category,
    );
  }

  factory PlannerTaskModel.fromEntity(PlannerTaskEntity entity) {
    final dateStr = "${entity.date.year.toString().padLeft(4, '0')}-${entity.date.month.toString().padLeft(2, '0')}-${entity.date.day.toString().padLeft(2, '0')}";
    return PlannerTaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dateIso: dateStr,
      timeString: entity.timeString,
      isCompleted: entity.isCompleted,
      category: entity.category,
    );
  }
}
