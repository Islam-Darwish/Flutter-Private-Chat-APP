import 'package:flutter/material.dart';
import 'package:private_chat/screens/main_screen/screens/contacts_screen/all_contacts_screen.dart';
import 'package:private_chat/screens/main_screen/screens/contacts_screen/available_contacts_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Widget> screens = <Widget>[
    AvailableContactsScreen(),
    AllContactsScreen(),
  ];
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'AVAILABLE'),
    Tab(text: 'ALL CONTACTS'),
  ];
  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: tabs,
          onTap: (value) {
            setState(() {});
          },
        ),
        Expanded(
          child: screens[_tabController.index],
        )
      ],
    );
  }
}
