import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:private_chat/models/message.dart';
import 'package:private_chat/providers/hive_provider.dart';
import 'package:private_chat/utils/enums.dart';

class FirebaseProvider with ChangeNotifier {
  FirebaseProvider(this._hiveProvider);
  final HiveProvider _hiveProvider;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  static const _messagingKey =
      'AAAASj22SU0:APA91bHutZUefDxb_3_QeluoTsgGpU_66gwN_WG-OaV69JgIadyC44XpfnD4nagapJpWwJnjWXf1IXtf1-mm8QOwJq9zTCmmMZC_Vb7owcyIZB5H_9d9kj6JAgwx3DjEuN3Z5n-u5fZ2';

  late String verificationID;
  User? get firebaseUser => _firebaseAuth.currentUser;
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
    String resultMessage = '';
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 30),
      verificationCompleted: (phoneAuthCredential) async {
        await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        resultMessage = 'codeSent';
      },
      verificationFailed: (error) {
        resultMessage = error.message ?? 'unknown error';
      },
      codeSent: (verificationId, forceResendingToken) {
        resultMessage = 'codeSent';
        verificationID = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
    return resultMessage;
  }

  Future<bool> sendOTP(String otpCode) async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otpCode);
    try {
      await _firebaseAuth.signInWithCredential(phoneAuthCredential);
    } catch (e) {
      return false;
    }
    if (firebaseUser != null)
      return true;
    else
      return false;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> uploadImageProfile(File image) async {
    final task = await FirebaseStorage.instance
        .ref(firebaseUser!.phoneNumber)
        .child(firebaseUser!.phoneNumber!)
        .putFile(image);
    if (task.state == TaskState.success) {
      await firebaseUser!.updatePhotoURL(await task.ref.getDownloadURL());
      notifyListeners();
    }
  }

  Future<void> removeProfileImage() async {
    try {
      await FirebaseStorage.instance
          .ref(firebaseUser!.phoneNumber)
          .child(firebaseUser!.phoneNumber!)
          .delete();
    } catch (e) {}
    await firebaseUser!.updatePhotoURL('deleted');
    notifyListeners();
  }

  Future<Uint8List?> getImageForNumber(String phoneNumber) async {
    try {
      var resultList = await FirebaseStorage.instance.ref(phoneNumber).list();
      if (resultList.items.length == 0) return null;
      return await resultList.items.first.getData();
    } catch (e) {
      return null;
    }
  }

  Future registerMyToken() async {
    String? token = await _firebaseMessaging.getToken(vapidKey: _messagingKey);
    if (token == null) return;
    _firebaseDatabase
        .reference()
        .child('Users')
        .child(_firebaseAuth.currentUser!.phoneNumber!)
        .set(token);
  }

  Future<String> getTokenForPhoneNumber(String phoneNumber) async {
    String token = '';
    try {
      token = (await _firebaseDatabase
              .reference()
              .child('Users')
              .child(phoneNumber)
              .once())
          .value;
    } catch (e) {
      token = '';
    }
    return token;
  }

  sendMessage(Message message, String toPhone) async {
    String token = await getTokenForPhoneNumber(toPhone);
    if (token.isEmpty) {
      message.messageStatus = MessageStatus.FAILED;
      message.time = DateTime.now().millisecondsSinceEpoch;
      await _hiveProvider.addMessage(toPhone, message);
      return;
    }
    var dio = Dio(
      BaseOptions(
          baseUrl: 'https://fcm.googleapis.com/fcm',
          connectTimeout: 5000,
          receiveTimeout: 5000,
          headers: {
            'Authorization':
                'key=AAAASj22SU0:APA91bHutZUefDxb_3_QeluoTsgGpU_66gwN_WG-OaV69JgIadyC44XpfnD4nagapJpWwJnjWXf1IXtf1-mm8QOwJq9zTCmmMZC_Vb7owcyIZB5H_9d9kj6JAgwx3DjEuN3Z5n-u5fZ2'
          },
          contentType: 'application/json'),
    );
    var response = await dio.post<String>('/send', data: {
      'to': token,
      'collapse_key': 'new_message',
      'data': {
        'fromPhone': _firebaseAuth.currentUser!.phoneNumber,
        'message': message.message,
        'time': DateTime.now().millisecondsSinceEpoch,
        'messageStatus': MessageStatus.SENT.index
      }
    });
    if (response.data == null) {
      message.messageStatus = MessageStatus.FAILED;
      message.time = DateTime.now().millisecondsSinceEpoch;
      await _hiveProvider.addMessage(toPhone, message);
      return;
    }
    var json = jsonDecode(response.data!);
    bool success = (json['success'] as int) == 1;
    if (success) {
      List results = json['results'];
      String messageId =
          (results.firstWhere((element) => element.keys.first == 'message_id'))
              .values
              .first;
      message.messageStatus = MessageStatus.SENT;
      message.id = messageId;
      message.time = DateTime.now().millisecondsSinceEpoch;
      await _hiveProvider.addMessage(toPhone, message);
    } else {
      message.messageStatus = MessageStatus.FAILED;
      message.time = DateTime.now().millisecondsSinceEpoch;
      await _hiveProvider.addMessage(toPhone, message);
    }
  }

  updateMessageStatus(
      String toPhone, String messageId, MessageStatus newStatus) async {
    String token = await getTokenForPhoneNumber(toPhone);
    if (token.isEmpty) {
      return;
    }
    var dio = Dio(
      BaseOptions(
          baseUrl: 'https://fcm.googleapis.com/fcm',
          connectTimeout: 5000,
          receiveTimeout: 5000,
          headers: {
            'Authorization':
                'key=AAAASj22SU0:APA91bHutZUefDxb_3_QeluoTsgGpU_66gwN_WG-OaV69JgIadyC44XpfnD4nagapJpWwJnjWXf1IXtf1-mm8QOwJq9zTCmmMZC_Vb7owcyIZB5H_9d9kj6JAgwx3DjEuN3Z5n-u5fZ2'
          },
          contentType: 'application/json'),
    );
    await dio.post('/send', data: {
      'to': token,
      'collapse_key': 'update_state',
      'data': {
        'fromPhone': _firebaseAuth.currentUser!.phoneNumber,
        'messageId': messageId,
        'newStatus': newStatus.index
      }
    });
  }

  Future handleForegroundMessage(RemoteMessage message) async {
    if (message.collapseKey == 'new_message') {
      if (message.data['fromPhone'] == null ||
          (message.data['fromPhone'] as String).isEmpty ||
          (message.data['fromPhone'] as String) ==
              _firebaseAuth.currentUser!.phoneNumber) return;
      //build message
      var messageData = Message(
          id: message.messageId,
          messageStatus: MessageStatus.RECIEVED,
          time: (message.sentTime ??
                  DateTime.fromMillisecondsSinceEpoch((message.data['time'] ??
                      DateTime.now().millisecondsSinceEpoch) as int))
              .millisecondsSinceEpoch);
      messageData.readData(message.data);
      //add message to database
      await _hiveProvider.addMessage(message.data['fromPhone'], messageData);
    } else if (message.collapseKey == 'update_state') {
      if (message.data['fromPhone'] == null ||
          (message.data['fromPhone'] as String).isEmpty ||
          (message.data['fromPhone'] as String) ==
              _firebaseAuth.currentUser!.phoneNumber) return;
      String fromPhone = message.data['fromPhone'];
      String messageId = message.data['messageId'];
      MessageStatus newStatus =
          MessageStatus.values[int.parse(message.data['newStatus'])];
      await _hiveProvider.updateMessageState(fromPhone, messageId, newStatus);
    }
  }

  static Future handleBackgroundMessage(RemoteMessage message) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (message.collapseKey == 'new_message') {
      if (message.data['fromPhone'] == null ||
          (message.data['fromPhone'] as String).isEmpty ||
          (message.data['fromPhone'] as String) ==
              firebaseAuth.currentUser!.phoneNumber) return;
      //build message
      var messageData = Message(
          id: message.messageId,
          messageStatus: MessageStatus.RECIEVED,
          time: (message.sentTime ??
                  DateTime.fromMillisecondsSinceEpoch((message.data['time'] ??
                      DateTime.now().millisecondsSinceEpoch) as int))
              .millisecondsSinceEpoch);
      messageData.readData(message.data);
      //add message to database
      await HiveProvider.addMessageInBackground(
          (message.data['fromPhone'] as String), messageData);
    } else if (message.collapseKey == 'update_state') {
      if (message.data['fromPhone'] == null ||
          (message.data['fromPhone'] as String).isEmpty ||
          (message.data['fromPhone'] as String) ==
              firebaseAuth.currentUser!.phoneNumber) return;
      String fromPhone = message.data['fromPhone'];
      String messageId = message.data['messageId'];
      MessageStatus newStatus =
          MessageStatus.values[int.parse(message.data['newStatus'])];
      await HiveProvider.updateMessageStateInBackground(
          firebaseAuth.currentUser!, fromPhone, messageId, newStatus);
    }
  }
}
