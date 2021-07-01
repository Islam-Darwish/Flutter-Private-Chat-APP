import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 0,
    centerTitle: true,
    actionsIconTheme: IconThemeData(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      headline1: TextStyle(
          color: Colors.black54, fontSize: 66, fontWeight: FontWeight.w300),
      headline2: TextStyle(
          color: Colors.black54, fontSize: 66, fontWeight: FontWeight.w300),
      headline3: TextStyle(
          color: Colors.black54, fontSize: 50, fontWeight: FontWeight.w300),
      headline4: TextStyle(
          color: Colors.black54, fontSize: 44, fontWeight: FontWeight.w300),
      headline5: TextStyle(
          color: Colors.black54, fontSize: 36, fontWeight: FontWeight.w300),
      headline6: TextStyle(
          color: Colors.black54, fontSize: 30, fontWeight: FontWeight.w300),
      bodyText1: TextStyle(
          color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
      bodyText2: TextStyle(
          color: Colors.black54, fontSize: 20, fontWeight: FontWeight.w300),
    ),
  ),
  accentColor: Colors.blueAccent,
  backgroundColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  tabBarTheme: TabBarTheme(
    labelColor: Colors.black,
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
        color: Colors.black54, fontSize: 66, fontWeight: FontWeight.w300),
    headline2: TextStyle(
        color: Colors.black54, fontSize: 66, fontWeight: FontWeight.w300),
    headline3: TextStyle(
        color: Colors.black54, fontSize: 50, fontWeight: FontWeight.w300),
    headline4: TextStyle(
        color: Colors.black54, fontSize: 44, fontWeight: FontWeight.w300),
    headline5: TextStyle(
        color: Colors.black54, fontSize: 36, fontWeight: FontWeight.w300),
    headline6: TextStyle(
        color: Colors.black54, fontSize: 30, fontWeight: FontWeight.w300),
    bodyText1: TextStyle(
        color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
    bodyText2: TextStyle(
        color: Colors.black54, fontSize: 20, fontWeight: FontWeight.w300),
  ),
);
ThemeData darkTheme = ThemeData.dark().copyWith();
