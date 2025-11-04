// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_transaksi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModelTransaksiAdapter extends TypeAdapter<ModelTransaksi> {
  @override
  final int typeId = 1;

  @override
  ModelTransaksi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModelTransaksi(
      id: fields[0] as String,
      idMobil: fields[1] as String,
      namaMobil: fields[2] as String,
      hargaMobil: fields[3] as String,
      namaPembeli: fields[4] as String,
      emailPembeli: fields[5] as String,
      nomorTelepon: fields[6] as String,
      metodePembayaran: fields[7] as String,
      mataUang: fields[8] as String?,
      jumlahPembayaran: fields[9] as String?,
      tanggalTransaksi: fields[10] as DateTime,
      status: fields[11] as String,
      catatan: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ModelTransaksi obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idMobil)
      ..writeByte(2)
      ..write(obj.namaMobil)
      ..writeByte(3)
      ..write(obj.hargaMobil)
      ..writeByte(4)
      ..write(obj.namaPembeli)
      ..writeByte(5)
      ..write(obj.emailPembeli)
      ..writeByte(6)
      ..write(obj.nomorTelepon)
      ..writeByte(7)
      ..write(obj.metodePembayaran)
      ..writeByte(8)
      ..write(obj.mataUang)
      ..writeByte(9)
      ..write(obj.jumlahPembayaran)
      ..writeByte(10)
      ..write(obj.tanggalTransaksi)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.catatan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelTransaksiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
