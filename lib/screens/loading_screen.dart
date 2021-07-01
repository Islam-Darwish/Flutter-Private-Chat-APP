import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:private_chat/providers/contacts_provider.dart';
import 'package:private_chat/providers/firebase_provider.dart';
import 'package:private_chat/providers/hive_provider.dart';
import './main_screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future loadData(BuildContext context) async {
    FirebaseProvider firebaseProvider =
        Provider.of<FirebaseProvider>(context, listen: false);
    ContactsProvider contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    HiveProvider hiveProvider =
        Provider.of<HiveProvider>(context, listen: false);
    //check login
    if (firebaseProvider.firebaseUser != null) {
      firebaseProvider.registerMyToken();
      PermissionStatus permission = await Permission.contacts.status;
      if (permission == PermissionStatus.granted) {
        await contactsProvider.loadAllContacts();
        contactsProvider.loadAvailableContacts();
      }
      //load user database
      await hiveProvider.init();
      await hiveProvider.loadChatList();
      await Future.delayed(Duration(seconds: 1));

      //navigate to home screen
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => loadData(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Private Chat',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
  }
}
