// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitDataModelAdapter extends TypeAdapter<HabitDataModel> {
  @override
  final int typeId = 0;

  @override
  HabitDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitDataModel(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      colorValue: fields[3] as int,
      frequency: (fields[4] as List).cast<int>(),
      reminderTime: fields[5] as String?,
      targetCount: fields[6] as int,
      unit: fields[7] as String?,
      categoryId: fields[8] as String?,
      sortOrder: fields[9] as int,
      isArchived: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      userId: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitDataModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.targetCount)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.categoryId)
      ..writeByte(9)
      ..write(obj.sortOrder)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
