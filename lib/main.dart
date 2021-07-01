import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:private_chat/providers/hive_provider.dart';
import 'package:private_chat/screens/chat_screen.dart';
import 'package:private_chat/utils/enums.dart';
import 'package:provider/provider.dart';
import 'models/chat.dart';
import 'models/message.dart';
import 'providers/contacts_provider.dart';
import 'providers/firebase_provider.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen/main_screen.dart';
import 'utils/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(ChatAdapter().typeId))
    Hive.registerAdapter(ChatAdapter());
  if (!Hive.isAdapterRegistered(MessageAdapter().typeId))
    Hive.registerAdapter(MessageAdapter());
  if (!Hive.isAdapterRegistered(MessageStatusAdapter().typeId))
    Hive.registerAdapter(MessageStatusAdapter());
  if (!Hive.isBoxOpen('private_chat')) {
    await Hive.openBox<Chat>('private_chat');
  } else {
    Hive.box<Chat>('private_chat');
  }
  print("Handling a background message: ${message.messageId}");
  FirebaseProvider.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(ChatAdapter().typeId))
    Hive.registerAdapter(ChatAdapter());
  if (!Hive.isAdapterRegistered(MessageAdapter().typeId))
    Hive.registerAdapter(MessageAdapter());
  if (!Hive.isAdapterRegistered(MessageStatusAdapter().typeId))
    Hive.registerAdapter(MessageStatusAdapter());
  if (!Hive.isBoxOpen('private_chat')) {
    await Hive.openBox<Chat>('private_chat');
  } else {
    Hive.box<Chat>('private_chat');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<HiveProvider>(
            create: (context) => HiveProvider()),
        ChangeNotifierProvider<FirebaseProvider>(
            create: (context) => FirebaseProvider(
                Provider.of<HiveProvider>(context, listen: false))),
        ChangeNotifierProvider<ContactsProvider>(
            create: (context) => ContactsProvider(
                Provider.of<FirebaseProvider>(context, listen: false))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      Provider.of<FirebaseProvider>(context, listen: false)
          .handleForegroundMessage(message);
    });
    return MaterialApp(
      title: 'Private Chat',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => LoadingScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        MainScreen.routeName: (context) => MainScreen(),
        ChatScreen.routeName: (context) => ChatScreen(),
      },
    );
  }
}
