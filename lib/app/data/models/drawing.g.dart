// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingStrokeAdapter extends TypeAdapter<DrawingStroke> {
  @override
  final int typeId = 3;

  @override
  DrawingStroke read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawingStroke(
      pointsData: (fields[0] as List).cast<double>(),
      colorValue: fields[1] as int,
      strokeWidth: fields[2] as double,
      isEraser: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DrawingStroke obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.pointsData)
      ..writeByte(1)
      ..write(obj.colorValue)
      ..writeByte(2)
      ..write(obj.strokeWidth)
      ..writeByte(3)
      ..write(obj.isEraser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingStrokeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrawingAdapter extends TypeAdapter<Drawing> {
  @override
  final int typeId = 2;

  @override
  Drawing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drawing(
      id: fields[0] as String,
      documentId: fields[1] as String,
      pageIndex: fields[2] as int,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      colorValue: fields[5] as int,
      strokes: (fields[6] as List).cast<DrawingStroke>(),
    );
  }

  @override
  void write(BinaryWriter writer, Drawing obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.strokes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
