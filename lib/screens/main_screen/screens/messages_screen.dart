import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:private_chat/providers/contacts_provider.dart';
import 'package:private_chat/providers/hive_provider.dart';
import 'package:private_chat/screens/chat_screen.dart';
import 'package:private_chat/utils/enums.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HiveProvider hiveProvider = Provider.of<HiveProvider>(context);
    ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    return HiveProvider.chatList.length == 0
        ? Center(
            child: Text('No messages yet.'),
          )
        : LayoutBuilder(
            builder: (context, constraints) => ListView.builder(
              itemBuilder: (context, index) {
                Contact? contact = contactsProvider.findContactByPhoneNumber(
                    HiveProvider.chatList[index].phoneNumber);

                return Dismissible(
                  key: Key(HiveProvider.chatList[index].phoneNumber),
                  onDismissed: (direction) {},
                  direction: DismissDirection.startToEnd,
                  background: Container(
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                  ),
                  confirmDismiss: (direction) {
                    return showDialog(
                      context: context,
                      builder: (context) => Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).accentColor),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Delete?',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      hiveProvider.deleteChat(HiveProvider
                                          .chatList[index].phoneNumber);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('ok',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!),
                                  ),
                                  MaterialButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'cancel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(color: Colors.red),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: FutureBuilder(
                      future: contactsProvider
                          .getPhoto(HiveProvider.chatList[index].phoneNumber),
                      builder: (context, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? CircleAvatar(
                                  child: Icon(Icons.person),
                                  foregroundImage: (contact != null &&
                                          contact.photoOrThumbnail != null)
                                      ? MemoryImage(contact.photoOrThumbnail!)
                                      : null,
                                )
                              : CircleAvatar(
                                  child: Icon(Icons.person),
                                  foregroundImage: (snapshot.data != null)
                                      ? MemoryImage(snapshot.data! as Uint8List)
                                      : null,
                                ),
                    ),
                    title: contact != null
                        ? Text(
                            contact.displayName,
                            style:
                                HiveProvider.chatList[index].messages.isNotEmpty
                                    ? (HiveProvider.chatList[index].messages
                                                    .last.fromPhone ==
                                                HiveProvider.chatList[index]
                                                    .phoneNumber &&
                                            HiveProvider
                                                    .chatList[index]
                                                    .messages
                                                    .last
                                                    .messageStatus !=
                                                MessageStatus.RECIEVED_READED)
                                        ? Theme.of(context).textTheme.bodyText1
                                        : Theme.of(context).textTheme.bodyText2
                                    : Theme.of(context).textTheme.bodyText2,
                          )
                        : Text(
                            HiveProvider.chatList[index].phoneNumber,
                            style:
                                HiveProvider.chatList[index].messages.isNotEmpty
                                    ? (HiveProvider.chatList[index].messages
                                                    .last.fromPhone ==
                                                HiveProvider.chatList[index]
                                                    .phoneNumber &&
                                            HiveProvider
                                                    .chatList[index]
                                                    .messages
                                                    .last
                                                    .messageStatus !=
                                                MessageStatus.RECIEVED_READED)
                                        ? Theme.of(context).textTheme.bodyText1
                                        : Theme.of(context).textTheme.bodyText2
                                    : Theme.of(context).textTheme.bodyText1,
                          ),
                    subtitle: Text(
                      HiveProvider.chatList[index].messages.isNotEmpty
                          ? HiveProvider
                                  .chatList[index].messages.last.message ??
                              ''
                          : '',
                      style: HiveProvider.chatList[index].messages.isNotEmpty
                          ? (HiveProvider.chatList[index].messages.last
                                          .fromPhone ==
                                      HiveProvider
                                          .chatList[index].phoneNumber &&
                                  HiveProvider.chatList[index].messages.last
                                          .messageStatus !=
                                      MessageStatus.RECIEVED_READED)
                              ? Theme.of(context).textTheme.bodyText1
                              : Theme.of(context).textTheme.bodyText2
                          : Theme.of(context).textTheme.bodyText1,
                    ),
                    trailing: HiveProvider.chatList[index].messages.isNotEmpty
                        ? (HiveProvider.chatList[index].messages.last
                                        .fromPhone ==
                                    HiveProvider.chatList[index].phoneNumber &&
                                HiveProvider.chatList[index].messages.last
                                        .messageStatus !=
                                    MessageStatus.RECIEVED_READED)
                            ? Icon(
                                Icons.circle,
                                color: Theme.of(context).accentColor,
                              )
                            : null
                        : null,
                    onTap: () => Navigator.of(context).pushNamed(
                        ChatScreen.routeName,
                        arguments: HiveProvider.chatList[index].phoneNumber),
                  ),
                );
              },
              itemCount: HiveProvider.chatList.length,
            ),
          );
  }
}
