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
    final fields = <int, dynamic>{};
    
    // Read fields - handle backward compatibility for old data
    // Old data might have written 6 as numOfFields but only 5 actual fields
    int fieldsRead = 0;
    while (fieldsRead < numOfFields) {
      try {
        final fieldIndex = reader.readByte();
        fields[fieldIndex] = reader.read();
        fieldsRead++;
      } catch (e) {
        // Old data format issue - stop reading if we run out of bytes
        break;
      }
    }
    
    return CredentialsModel(
      id: fields[0] as String?,
      title: fields[1] as String?,
      apiKey: fields[2] as String?,
      secret: fields[3] as String?,
      externalId: fields[4] as String?,
      credentialType: fields[5] as String?, // Will be null for old data
    );
  }

  @override
  void write(BinaryWriter writer, CredentialsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.apiKey)
      ..writeByte(3)
      ..write(obj.secret)
      ..writeByte(4)
      ..write(obj.externalId)
      ..writeByte(5)
      ..write(obj.credentialType);
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
