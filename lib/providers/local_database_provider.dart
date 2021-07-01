// import 'package:flutter/foundation.dart';
// import 'package:private_chat/models/chat.dart';
// import 'package:private_chat/models/message.dart';
// import 'package:private_chat/utils/enums.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class LocalDatabaseProvider with ChangeNotifier {
//   Database? _db;
//   List<Chat> chatList = [];
//   LocalDatabaseProvider() {
//     _open();
//   }
//   _open() async {
//     // Get a location using getDatabasesPath
//     var databasesPath = await getDatabasesPath();
//     String path = join(databasesPath, 'private_chat.db');
//     _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
//       try {
//         await db.execute(
//             'create table Chats ( id integer primary key autoincrement,  phoneNumber text not null)');
//       } catch (e) {}
//     });
//   }

//   loadOpendChats() async {
//     if (_db == null || !_db!.isOpen) {
//       try {
//         await _open();
//       } catch (e) {}
//     }
//     chatList = [];
//     var openChats = await _db!.rawQuery('SELECT * FROM Chats');
//     openChats.forEach((chat) {
//       if (!chatList
//           .any((element) => element.phoneNumber == chat['phoneNumber']!)) {
//         chatList.add(Chat(chat['phoneNumber']! as String));
//       }
//     });
//     for (int i = 0; i < chatList.length; i++) {
//       try {
//         chatList[i].messages = (await _db!.query(chatList[i].phoneNumber))
//             .map((e) => Message.fromJson(e))
//             .toList();
//       } catch (e) {}
//     }
//     chatList.sort();
//     notifyListeners();
//   }

//   insertMessageInDatabase(String table, Message message) async {
//     if (_db == null || !_db!.isOpen) {
//       try {
//         await _open();
//       } catch (e) {}
//     }
//     try {
//       await _db!.query(table);
//     } catch (e) {
//       //table not found create new one
//       try {
//         await _db!.execute(
//             'create table $table (id text primary key, fromPhone text not null, message text not null, time integer not null, messageStatus integer not null)');
//       } catch (e) {}
//     }
//     List<Map> maps = await _db!.query(table,
//         where: 'id = ?', columns: ['id'], whereArgs: [message.id ?? '']);
//     if (maps.isEmpty) {
//       try {
//         await _db!.rawInsert(
//             'INSERT INTO $table(id, fromPhone, message, time, messageStatus) VALUES(${message.id}, ${message.fromPhone}, ${message.message}, ${message.time}, ${(message.messageStatus ?? MessageStatus.FAILED).index})');
//       } catch (e) {
//         print(e);
//       }
//     } else {
//       try {
//         await _db!.update(table, message.toJson(),
//             where: 'id = ?', whereArgs: [message.id]);
//       } catch (e) {
//         print(e);
//       }
//     }
//     List<Map> openChat = await _db!.query('Chats',
//         where: 'phoneNumber = ?',
//         columns: ['id', 'phoneNumber'],
//         whereArgs: [message.fromPhone]);
//     if (openChat.isEmpty)
//       await _db!.insert('Chats', {'phoneNumber': message.fromPhone});
//   }

//   updateMessageStatusInDatabase(
//       String fromPhone, String messageId, int newStatus) async {
//     if (_db == null || !_db!.isOpen) {
//       try {
//         await _open();
//       } catch (e) {}
//     }
//     try {
//       await _db!.update(fromPhone, {'messageStatus': newStatus},
//           where: 'id = ?', whereArgs: [messageId]);
//     } catch (e) {}
//   }

//   addMessageToChatList(String phoneNumber, Message message) {
//     int index =
//         chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
//     if (index != -1) {
//       chatList[index].messages.add(message);
//       chatList.sort();
//     } else {
//       chatList.add(Chat(phoneNumber)..messages.add(message));
//       chatList.sort();
//     }
//     notifyListeners();
//   }

//   updateMessageInChatList(String phoneNumber, String messageId, int newState) {
//     int index =
//         chatList.indexWhere((element) => element.phoneNumber == phoneNumber);
//     if (index != -1) {
//       try {
//         chatList[index]
//             .messages
//             .lastWhere((message) => message.id == messageId)
//             .messageStatus = MessageStatus.values[newState];
//       } catch (e) {
//         print(e);
//       }
//       chatList.sort();
//     }
//     notifyListeners();
//   }

//   deleteReceivedMessage(String phoneNumber, String messageId) async {
//     if (_db == null || !_db!.isOpen) {
//       try {
//         await _open();
//       } catch (e) {}
//     }
//     try {
//       await _db!.delete(phoneNumber, where: 'id = ?', whereArgs: [messageId]);
//     } catch (e) {}
//     notifyListeners();
//   }

//   deleteChatList(String phoneNumber) async {
//     if (_db == null || !_db!.isOpen) {
//       try {
//         await _open();
//       } catch (e) {}
//     }
//     try {
//       await _db!.rawQuery('drop table $phoneNumber');
//       await _db!
//           .delete('Chats', where: 'phoneNumber = ?', whereArgs: [phoneNumber]);
//       await loadOpendChats();
//       notifyListeners();
//     } catch (e) {}
//   }

//   static bgInsertMessageInDatabase(String table, Message message) async {
//     var databasesPath = await getDatabasesPath();
//     String path = join(databasesPath, 'private_chat.db');
//     Database _db =
//         await openDatabase(path, version: 1, onCreate: (db, version) async {
//       try {
//         await db.execute(
//             'create table Chats ( id integer primary key autoincrement,  phoneNumber text not null)');
//       } catch (e) {}
//     });
//     try {
//       await _db.query(table);
//     } catch (e) {
//       //table not found create new one
//       try {
//         await _db.execute(
//             'create table $table (id text not null, fromPhone text not null, message text not null, time integer not null, messageStatus integer not null)');
//       } catch (e) {}
//     }
//     List<Map> maps = await _db.query(table,
//         where: 'id = ?',
//         columns: ['id', 'fromPhone', 'message', 'time', 'messageStatus'],
//         whereArgs: [message.id]);
//     if (maps.isEmpty) {
//       await _db.insert(table, message.toJson());
//     } else {
//       await _db.update(table, message.toJson(),
//           where: 'id = ?', whereArgs: [message.id]);
//     }
//     List<Map> openChat = await _db.query('Chats',
//         where: 'phoneNumber = ?',
//         columns: ['id', 'phoneNumber'],
//         whereArgs: [message.fromPhone]);
//     if (openChat.isEmpty)
//       await _db.insert('Chats', {'phoneNumber': message.fromPhone});
//   }

//   static bgUpdateMessageStatusInDatabase(
//       String fromPhone, String messageId, int newStatus) async {
//     var databasesPath = await getDatabasesPath();
//     String path = join(databasesPath, 'private_chat.db');
//     Database _db =
//         await openDatabase(path, version: 1, onCreate: (db, version) async {
//       try {
//         await db.execute(
//             'create table Chats ( id integer primary key autoincrement,  phoneNumber text not null)');
//       } catch (e) {}
//     });
//     try {
//       await _db.update(fromPhone, {'messageStatus': newStatus},
//           where: 'id = ?', whereArgs: [messageId]);
//     } catch (e) {}
//   }

//   static bgDeleteReceivedMessage(String phoneNumber, String messageId) async {
//     var databasesPath = await getDatabasesPath();
//     String path = join(databasesPath, 'private_chat.db');
//     Database _db =
//         await openDatabase(path, version: 1, onCreate: (db, version) async {
//       try {
//         await db.execute(
//             'create table Chats ( id integer primary key autoincrement,  phoneNumber text not null)');
//       } catch (e) {}
//     });
//     try {
//       await _db.delete(phoneNumber, where: 'id = ?', whereArgs: [messageId]);
//     } catch (e) {}
//   }
// }
