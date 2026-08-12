import 'package:equatable/equatable.dart';

class PlannerTaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String? timeString;
  final bool isCompleted;
  final String category;
  final String userId;

  const PlannerTaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.timeString,
    this.isCompleted = false,
    this.category = 'General',
    this.userId = '',
  });

  PlannerTaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? timeString,
    bool? isCompleted,
    String? category,
    String? userId,
  }) {
    return PlannerTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      timeString: timeString ?? this.timeString,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    date,
    timeString,
    isCompleted,
    category,
    userId,
  ];
}
