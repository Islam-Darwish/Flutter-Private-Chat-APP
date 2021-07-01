// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 2;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.SENT;
      case 1:
        return MessageStatus.FAILED;
      case 2:
        return MessageStatus.RECIEVED;
      case 3:
        return MessageStatus.RECIEVED_READED;
      case 4:
        return MessageStatus.DELETED;
      default:
        return MessageStatus.SENT;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.SENT:
        writer.writeByte(0);
        break;
      case MessageStatus.FAILED:
        writer.writeByte(1);
        break;
      case MessageStatus.RECIEVED:
        writer.writeByte(2);
        break;
      case MessageStatus.RECIEVED_READED:
        writer.writeByte(3);
        break;
      case MessageStatus.DELETED:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
