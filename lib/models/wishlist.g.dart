// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishListAdapter extends TypeAdapter<WishList> {
  @override
  final int typeId = 0;

  @override
  WishList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishList(
      id: fields[0] as String,
      title: fields[1] as String,
      deadline: fields[2] as DateTime,
      tasks: (fields[3] as List).cast<Task>(),
    );
  }

  @override
  void write(BinaryWriter writer, WishList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
