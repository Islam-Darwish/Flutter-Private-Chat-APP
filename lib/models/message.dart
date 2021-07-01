import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:private_chat/utils/enums.dart';
import 'dart:convert';
part 'message.g.dart';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

@HiveType(typeId: 0)
class Message extends HiveObject with Comparable {
  Message({
    this.id,
    this.fromPhone,
    this.message,
    this.time,
    this.messageStatus,
  });

  @HiveField(0)
  String? id;
  @HiveField(1)
  String? fromPhone;
  @HiveField(2)
  String? message;
  @HiveField(3)
  int? time;
  @HiveField(4)
  MessageStatus? messageStatus;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] ?? '',
        fromPhone: json['fromPhone'] ?? '',
        message: json['message'] ?? '',
        time: json['time'] ?? 0,
        messageStatus: MessageStatus.values[json['messageStatus'] ?? 0],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromPhone': fromPhone,
        'message': message,
        'time': time,
        'messageStatus': (messageStatus ?? MessageStatus.RECIEVED).index,
      };
  readData(Map<String, dynamic> json) {
    this.fromPhone = json['fromPhone'] ?? '';
    this.message = json['message'] ?? '';
  }

  @override
  int compareTo(other) {
    if ((this.time ?? 0) < (other.time ?? 0))
      return -1;
    else if ((this.time ?? 0) == (other.time ?? 0))
      return 0;
    else
      return 1;
  }

  @override
  bool operator ==(other) =>
      other is Message && this.id == other.id && this.message == other.message;

  @override
  int get hashCode => hashValues(id.hashCode, message.hashCode);
}
