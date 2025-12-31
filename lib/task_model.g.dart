// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      deadline: fields[1] as DateTime,
      subTasks: (fields[2] as List).cast<SubTask>(),
      filePaths: (fields[3] as List).cast<String>(),
      isHabit: fields[4] as bool,
      isCompleted: fields[5] as bool,
      previousSubTaskStatus: (fields[6] as List?)?.cast<bool>(),
      category: fields[7] == null ? 'Tugas Kuliah' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.deadline)
      ..writeByte(2)
      ..write(obj.subTasks)
      ..writeByte(3)
      ..write(obj.filePaths)
      ..writeByte(4)
      ..write(obj.isHabit)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.previousSubTaskStatus)
      ..writeByte(7)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 1;

  @override
  SubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubTask(
      title: fields[0] as String,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
