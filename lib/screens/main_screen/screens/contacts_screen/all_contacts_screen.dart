import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:private_chat/providers/contacts_provider.dart';
import 'package:provider/provider.dart';

class AllContactsScreen extends StatelessWidget {
  const AllContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FutureBuilder(
          future: contactsProvider.loadAllContacts(),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Container()
                  : ListView.builder(
                      itemBuilder: (context, index) => ContactTile(
                          index: index, contactsProvider: contactsProvider),
                      itemCount: contactsProvider.allContacts.length,
                    ),
        ),
      ),
    );
  }
}

class ContactTile extends StatefulWidget {
  const ContactTile({
    required this.index,
    required this.contactsProvider,
  });

  final ContactsProvider contactsProvider;
  final int index;

  @override
  _ContactTileState createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> {
  bool expand = false;
  late Contact contact;
  @override
  void initState() {
    contact = widget.contactsProvider.allContacts.elementAt(widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          expand = !expand;
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.displayName.toUpperCase().characters.first),
          foregroundImage: contact.thumbnail != null
              ? MemoryImage(contact.thumbnail!)
              : null,
        ),
        title: Text(
          contact.displayName,
          style: Theme.of(context).textTheme.bodyText1,
          overflow: TextOverflow.clip,
        ),
        subtitle: expand
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    ...contact.phones
                        .map((e) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.number,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                MaterialButton(
                                  onPressed: () {},
                                  child: Text('Invite'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: Theme.of(context).accentColor,
                                )
                              ],
                            ))
                        .toList()
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
