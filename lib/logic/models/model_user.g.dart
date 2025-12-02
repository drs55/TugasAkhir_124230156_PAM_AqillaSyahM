// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelUserAdapter extends TypeAdapter<ModelUser> {
  @override
  final int typeId = 2;

  @override
  ModelUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModelUser(
      id: fields[0] as String,
      nama: fields[1] as String,
      username: fields[2] as String,
      password: fields[3] as String,
      salt: fields[4] as String?,
      noTelepon: fields[5] as String?,
      alamat: fields[6] as String?,
      tanggalDaftar: fields[7] as DateTime,
      fotoProfil: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ModelUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.salt)
      ..writeByte(5)
      ..write(obj.noTelepon)
      ..writeByte(6)
      ..write(obj.alamat)
      ..writeByte(7)
      ..write(obj.tanggalDaftar)
      ..writeByte(8)
      ..write(obj.fotoProfil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
