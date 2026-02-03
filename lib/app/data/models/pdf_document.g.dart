// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfDocumentAdapter extends TypeAdapter<PdfDocument> {
  @override
  final int typeId = 0;

  @override
  PdfDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfDocument(
      id: fields[0] as String,
      title: fields[1] as String,
      filePath: fields[2] as String,
      pageCount: fields[3] as int,
      fileSize: fields[4] as int,
      addedAt: fields[5] as DateTime,
      lastOpenedAt: fields[6] as DateTime,
      lastPageIndex: fields[7] as int,
      isFavorite: fields[8] as bool,
      thumbnailPath: fields[9] as String?,
      collectionId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PdfDocument obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.pageCount)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.addedAt)
      ..writeByte(6)
      ..write(obj.lastOpenedAt)
      ..writeByte(7)
      ..write(obj.lastPageIndex)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.thumbnailPath)
      ..writeByte(10)
      ..write(obj.collectionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
