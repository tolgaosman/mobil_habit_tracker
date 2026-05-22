// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as String,
      colorHex: fields[3] as String,
      createdAt: fields[5] as String,
      completions: (fields[4] as List?)?.cast<HabitCompletion>(),
      notificationsEnabled: fields[6] as bool,
      notificationTime: fields[7] as String,
      repeatDays: (fields[8] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.completions)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.notificationTime)
      ..writeByte(8)
      ..write(obj.repeatDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitCompletionAdapter extends TypeAdapter<HabitCompletion> {
  @override
  final int typeId = 1;

  @override
  HabitCompletion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitCompletion(
      dateKey: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HabitCompletion obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.dateKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
