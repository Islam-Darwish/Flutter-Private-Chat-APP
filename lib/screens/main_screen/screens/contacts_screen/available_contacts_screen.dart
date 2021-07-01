import 'package:flutter/material.dart';
import 'package:private_chat/providers/contacts_provider.dart';
import 'package:private_chat/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class AvailableContactsScreen extends StatelessWidget {
  const AvailableContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ContactsProvider contactsProvider = Provider.of<ContactsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: ListView.builder(
          itemBuilder: (context, index) => AvailableContactTile(
              availableContact: contactsProvider.availableContacts[index],
              contactsProvider: contactsProvider),
          itemCount: contactsProvider.availableContacts.length,
        ),
      ),
    );
  }
}

class AvailableContactTile extends StatelessWidget {
  const AvailableContactTile({
    required this.availableContact,
    required this.contactsProvider,
  });
  final ContactsProvider contactsProvider;
  final AvailableContact availableContact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ChatScreen.routeName,
            arguments:
                availableContact.contact.phones[availableContact.phoneIndex].normalizedNumber);
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(availableContact.contact.displayName
              .toUpperCase()
              .characters
              .first),
          foregroundImage: availableContact.contact.thumbnail != null
              ? MemoryImage(availableContact.contact.thumbnail!)
              : null,
        ),
        title: Text(
          availableContact.contact.displayName,
          style: Theme.of(context).textTheme.bodyText1,
          overflow: TextOverflow.clip,
        ),
        subtitle: SingleChildScrollView(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              availableContact
                  .contact.phones[availableContact.phoneIndex].number,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      ),
    );
  }
}
