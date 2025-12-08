// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialsModelAdapter extends TypeAdapter<CredentialsModel> {
  @override
  final int typeId = 0;

  @override
  CredentialsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialsModel(
      id: fields[0] as String?,
      title: fields[1] as String?,
      apiKey: fields[2] as String?,
      secret: fields[3] as String?,
      externalId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CredentialsModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.apiKey)
      ..writeByte(3)
      ..write(obj.secret)
      ..writeByte(4)
      ..write(obj.externalId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
