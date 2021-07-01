import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:private_chat/models/chat.dart';
import 'package:private_chat/models/message.dart';
import 'package:private_chat/utils/enums.dart';

class HiveProvider with ChangeNotifier {
  late Box<Chat> box;
  static List<Chat> chatList = [];

  Future init() async {
    if (!Hive.isBoxOpen('private_chat')) {
      box = await Hive.openBox<Chat>('private_chat');
    } else {
      box = Hive.box<Chat>('private_chat');
    }
  }

  Future loadChatList() async {
    // await box.deleteFromDisk();
    await init();
    chatList = [];
    for (int i = 0; i < box.values.length; i++) {
      chatList.add(box.getAt(i)!);
    }
    chatList.sort();
  }

  Future refreshChatList() async {
    await init();
    if (box.isOpen)
      box = Hive.box<Chat>('private_chat');
    else
      Hive.openBox<Chat>('private_chat');
    chatList = [];
    for (int i = 0; i < box.values.length; i++) {
      chatList.add(box.getAt(i)!);
    }
    chatList.sort();
    notifyListeners();
  }

  Future addMessage(String phoneNumber, Message message) async {
    await init();
    int chatIndex =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (chatIndex != -1) {
      if (!chatList[chatIndex].messages.contains(message)) {
        chatList[chatIndex].addMessage(message);
        chatList.sort();
        chatList[chatIndex].save();
        notifyListeners();
      }
    } else {
      Chat chat = Chat(phoneNumber)..addMessage(message);
      int index = await box.add(chat);
      chatList.add(box.getAt(index)!);
      chatList.sort();
      notifyListeners();
    }
  }

  Future updateMessageState(
      String phoneNumber, String messageId, MessageStatus newState) async {
    await init();
    int chatIndex =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (chatIndex != -1) {
      int messageIndex = chatList[chatIndex]
          .messages
          .lastIndexWhere((element) => element.id == messageId);
      chatList[chatIndex].messages[messageIndex].messageStatus = newState;
      chatList.sort();
      chatList[chatIndex].save();
      notifyListeners();
    }
  }

  static Future addMessageInBackground(
      String phoneNumber, Message message) async {
    chatList = [];
    Box<Chat> box;
    if (!Hive.isBoxOpen('private_chat')) {
      box = await Hive.openBox<Chat>('private_chat');
    } else {
      box = Hive.box<Chat>('private_chat');
    }
    for (int i = 0; i < box.values.length; i++) {
      try {
        chatList.add(box.getAt(i)!);
      } catch (e) {}
    }
    chatList.sort();
    int chatIndex =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (chatIndex != -1) {
      if (!chatList[chatIndex].messages.contains(message)) {
        chatList[chatIndex].addMessage(message);
        chatList.sort();
        chatList[chatIndex].save();
      }
    } else {
      Chat chat = Chat(phoneNumber)..addMessage(message);
      int index = await box.add(chat);
      chatList.add(box.getAt(index)!);
      chatList.sort();
    }
  }

  static Future updateMessageStateInBackground(User firebaseUser,
      String phoneNumber, String messageId, MessageStatus newState) async {
    chatList = [];
    Box<Chat> box;
    if (!Hive.isBoxOpen('private_chat')) {
      box = await Hive.openBox<Chat>('private_chat');
    } else {
      box = Hive.box<Chat>('private_chat');
    }
    for (int i = 0; i < box.values.length; i++) {
      chatList.add(box.getAt(i)!);
    }
    chatList.sort();
    int chatIndex =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (chatIndex != -1) {
      int messageIndex = chatList
          .elementAt(chatIndex)
          .messages
          .lastIndexWhere((element) => element.id == messageId);
      chatList.elementAt(chatIndex).messages[messageIndex].messageStatus =
          newState;
      chatList.sort();
      chatList.elementAt(chatIndex).save();
      box.putAt(chatIndex, chatList.elementAt(chatIndex));
    }
  }

  Future deleteMessage(String phoneNumber, String messageId) async {
    await init();
    int chatIndex =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (chatIndex != -1) {
      int messageIndex = chatList
          .elementAt(chatIndex)
          .messages
          .lastIndexWhere((element) => element.id == messageId);
      chatList.elementAt(chatIndex).messages.removeAt(messageIndex);
      chatList.sort();
      chatList.elementAt(chatIndex).save();
    }
  }

  Future deleteChat(String phoneNumber) async {
    await init();
    int index =
        chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
    chatList.removeAt(index);
    await box.deleteAt(index);
    chatList.sort();
  }
}
