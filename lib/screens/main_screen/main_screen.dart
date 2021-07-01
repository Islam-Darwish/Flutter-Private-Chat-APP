import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:private_chat/providers/hive_provider.dart';
import 'package:private_chat/screens/main_screen/screens/contacts_screen/contacts_screen.dart';
import 'package:private_chat/screens/main_screen/screens/home_screen.dart';
import 'package:private_chat/screens/main_screen/screens/messages_screen.dart';
import 'package:private_chat/screens/main_screen/screens/more_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static final routeName = '/MainScreen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int currentPageIndex = 2;
  late HiveProvider hiveProvider;
  @override
  void initState() {
    super.initState();
    hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    // add the observer
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // remove the observer
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  var screens = [
    HomeScreen(),
    ContactsScreen(),
    MessagesScreen(),
    MoreScreen(),
  ];
  var titles = [
    'Home',
    'Friends',
    'Messages',
    'More',
  ];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await hiveProvider.refreshChatList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentPageIndex]),
      ),
      body: screens[currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [..._navBarsItems(context)],
        currentIndex: currentPageIndex,
        onTap: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _navBarsItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(
            'assets/images/home.svg',
            color: Theme.of(context).accentColor,
          ),
          icon: SvgPicture.asset(
            'assets/images/home.svg',
            color: Colors.grey,
          ),
          label: 'Home'),
      BottomNavigationBarItem(
        activeIcon: SvgPicture.asset(
          'assets/images/people.svg',
          color: Theme.of(context).accentColor,
        ),
        icon: SvgPicture.asset(
          'assets/images/people.svg',
          color: Colors.grey,
        ),
        label: 'friends',
      ),
      BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(
            'assets/images/chats.svg',
            color: Theme.of(context).accentColor,
          ),
          icon: SvgPicture.asset(
            'assets/images/chats.svg',
            color: Colors.grey,
          ),
          label: 'Chats'),
      BottomNavigationBarItem(
          activeIcon: SvgPicture.asset(
            'assets/images/more.svg',
            color: Theme.of(context).accentColor,
          ),
          icon: SvgPicture.asset(
            'assets/images/more.svg',
            color: Colors.grey,
          ),
          label: 'More'),
    ];
  }
}
