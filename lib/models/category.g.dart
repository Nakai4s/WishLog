// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 2;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.work;
      case 1:
        return TaskCategory.health;
      case 2:
        return TaskCategory.hobby;
      case 3:
        return TaskCategory.relationship;
      case 4:
        return TaskCategory.money;
      case 5:
        return TaskCategory.learning;
      case 6:
        return TaskCategory.other;
      default:
        return TaskCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.work:
        writer.writeByte(0);
        break;
      case TaskCategory.health:
        writer.writeByte(1);
        break;
      case TaskCategory.hobby:
        writer.writeByte(2);
        break;
      case TaskCategory.relationship:
        writer.writeByte(3);
        break;
      case TaskCategory.money:
        writer.writeByte(4);
        break;
      case TaskCategory.learning:
        writer.writeByte(5);
        break;
      case TaskCategory.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
