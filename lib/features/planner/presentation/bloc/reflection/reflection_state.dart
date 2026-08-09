import 'package:daily_habit/features/planner/domain/entities/daily_reflection_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ReflectionState extends Equatable {
  const ReflectionState();
  @override
  List<Object?> get props => [];
}

class ReflectionInitial extends ReflectionState {}
class ReflectionLoading extends ReflectionState {}
class ReflectionLoaded extends ReflectionState {
  final DateTime date;
  final DailyReflectionEntity? reflection;

  const ReflectionLoaded({
    required this.date,
    this.reflection,
  });

  @override
  List<Object?> get props => [date, reflection];
}

class ReflectionSaved extends ReflectionState {
  final DailyReflectionEntity reflection;
  const ReflectionSaved(this.reflection);

  @override
  List<Object?> get props => [reflection];
}

class ReflectionError extends ReflectionState {
  final String message;
  const ReflectionError(this.message);

  @override
  List<Object?> get props => [message];
}
