// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaItemModelAdapter extends TypeAdapter<MediaItemModel> {
  @override
  final int typeId = 1;

  @override
  MediaItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaItemModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      mediaType: fields[2] as String,
      fileBytes: (fields[3] as List).cast<int>(),
      fileSize: fields[4] as int,
      createdAt: fields[5] as DateTime,
      modifiedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MediaItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.mediaType)
      ..writeByte(3)
      ..write(obj.fileBytes)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.modifiedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
