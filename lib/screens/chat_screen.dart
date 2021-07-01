import 'dart:typed_data';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:private_chat/models/chat.dart';
import 'package:private_chat/models/message.dart';
import 'package:private_chat/providers/contacts_provider.dart';
import 'package:private_chat/providers/firebase_provider.dart';
import 'package:private_chat/providers/hive_provider.dart';
import 'package:private_chat/utils/enums.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late HiveProvider hiveProvider;
  late FirebaseProvider firebaseProvider;
  late ContactsProvider contactsProvider;
  late String phoneNumber;
  Contact? contact;
  late Chat chat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => markAsRead());
  }

  markAsRead() async {
    try {
      chat.messages
          .where((element) => (element.fromPhone == phoneNumber &&
              element.messageStatus != MessageStatus.RECIEVED_READED))
          .forEach((element) async {
        await firebaseProvider.updateMessageStatus(
            phoneNumber, element.id ?? '', MessageStatus.RECIEVED_READED);
        await hiveProvider.updateMessageState(
            phoneNumber, element.id ?? '', MessageStatus.RECIEVED_READED);
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    firebaseProvider = Provider.of<FirebaseProvider>(context);
    hiveProvider = Provider.of<HiveProvider>(context);
    contactsProvider = Provider.of<ContactsProvider>(context, listen: false);
    phoneNumber = ModalRoute.of(context)!.settings.arguments as String;
    contact = contactsProvider.findContactByPhoneNumber(phoneNumber);
    try {
      chat = HiveProvider.chatList.reversed
          .firstWhere((element) => element.phoneNumber == phoneNumber);
    } catch (e) {
      chat = Chat(phoneNumber);
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            FutureBuilder(
              future: contactsProvider.getPhoto(phoneNumber),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? CircleAvatar(
                          child: Icon(Icons.person),
                          foregroundImage: (contact != null &&
                                  contact!.photoOrThumbnail != null)
                              ? MemoryImage(contact!.photoOrThumbnail!)
                              : null,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                          foregroundImage: (snapshot.data != null)
                              ? MemoryImage(snapshot.data! as Uint8List)
                              : null,
                        ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(contact != null ? contact!.displayName : phoneNumber),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Container(
              height: constraints.maxHeight - 50,
              child: chat.messages.isEmpty
                  ? Center(
                      child: Text('No Messages Yet.'),
                    )
                  : ListView.builder(
                      itemCount: chat.messages.length,
                      reverse: true,
                      itemBuilder: (context, index) => Bubble(
                        nipHeight: 8,
                        showNip: true,
                        margin: BubbleEdges.only(top: 8, bottom: 8),
                        nipWidth: 15,
                        alignment: (chat.messages.reversed
                                    .elementAt(index)
                                    .fromPhone ==
                                firebaseProvider.firebaseUser!.phoneNumber)
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        nip: (chat.messages.reversed
                                    .elementAt(index)
                                    .fromPhone ==
                                firebaseProvider.firebaseUser!.phoneNumber)
                            ? BubbleNip.rightTop
                            : BubbleNip.leftTop,
                        color: (chat.messages.reversed
                                    .elementAt(index)
                                    .fromPhone ==
                                firebaseProvider.firebaseUser!.phoneNumber)
                            ? Theme.of(context).backgroundColor
                            : Theme.of(context).accentColor,
                        child: Text(
                            chat.messages.reversed.elementAt(index).message ??
                                ''),
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'Type Message...'),
                      maxLines: 5,
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * 0.15,
                    height: 50,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () async {
                        await firebaseProvider.sendMessage(
                            Message(
                              fromPhone:
                                  firebaseProvider.firebaseUser!.phoneNumber,
                              message: _controller.text,
                              time: DateTime.now().millisecondsSinceEpoch,
                              messageStatus: MessageStatus.SENT,
                            ),
                            phoneNumber);
                        _controller.text = '';
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
