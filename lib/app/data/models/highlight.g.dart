// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HighlightAdapter extends TypeAdapter<Highlight> {
  @override
  final int typeId = 1;

  @override
  Highlight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Highlight(
      id: fields[0] as String,
      documentId: fields[1] as String,
      pageIndex: fields[2] as int,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      colorValue: fields[5] as int,
      text: fields[6] as String,
      rectsData: (fields[7] as List).cast<double>(),
      note: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Highlight obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentId)
      ..writeByte(2)
      ..write(obj.pageIndex)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.rectsData)
      ..writeByte(8)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HighlightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
