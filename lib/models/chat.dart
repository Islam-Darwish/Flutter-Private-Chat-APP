import 'package:hive/hive.dart';
import 'package:private_chat/models/message.dart';
    part 'chat.g.dart';
@HiveType(typeId: 1, adapterName: 'ChatAdapter')
class Chat extends HiveObject with Comparable {
  @HiveField(0)
  String phoneNumber = '';
  @HiveField(1)
  List<Message> messages = [];

  Chat(String phone) {
    phoneNumber = phone;
  }
  addMessage(Message message) {
    messages.add(message);
    messages.sort();
  }

  @override
  int compareTo(other) {
    this.messages.sort();
    other.messages.sort();
    if (this.messages.isEmpty) return 1;
    if (other.messages.isEmpty) return -1;
    int thislastMessageTime = this.messages.last.time ?? 0;
    int otherlastMessageTime = other.messages.last.time ?? 0;
    if (thislastMessageTime < otherlastMessageTime)
      return 1;
    else if (thislastMessageTime > otherlastMessageTime)
      return -1;
    else
      return 0;
  }
}

