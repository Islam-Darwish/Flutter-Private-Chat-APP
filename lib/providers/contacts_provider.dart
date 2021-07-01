import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:private_chat/providers/firebase_provider.dart';

class ContactsProvider with ChangeNotifier {
  ContactsProvider(this.firebaseProvider);
  final FirebaseProvider firebaseProvider;
  List<Contact> allContacts = [];
  List<AvailableContact> availableContacts = [];
  Future<bool> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    return permissionStatus.isGranted;
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future loadAllContacts() async {
    if (allContacts.isNotEmpty) return;
    if (!await _askPermissions()) return;
    allContacts = await FlutterContacts.getContacts(
        withThumbnail: true,
        withProperties: true,
        withPhoto: true,
        sorted: true);
    notifyListeners();
  }

  Future loadAvailableContacts() async {
    if (allContacts.isNotEmpty) {
      for (int i = 0; i < allContacts.length; i++) {
        for (int j = 0; j < allContacts[i].phones.length; j++) {
          if (allContacts[i].phones[j].normalizedNumber.isEmpty ||
              allContacts[i].phones[j].normalizedNumber ==
                  firebaseProvider.firebaseUser!.phoneNumber) continue;
          String token = await firebaseProvider.getTokenForPhoneNumber(
              allContacts[i].phones[j].normalizedNumber);
          if (token.isNotEmpty) {
            availableContacts.add(AvailableContact(allContacts[i], j, token));
            notifyListeners();
          }
        }
      }
    }
  }

  Contact? findContactByPhoneNumber(String phoneNumber) {
    if (allContacts.isEmpty) return null;
    for (int i = 0; i < allContacts.length; i++) {
      for (int j = 0; j < allContacts[i].phones.length; j++) {
        if (allContacts[i].phones[j].normalizedNumber == phoneNumber)
          return allContacts[i];
      }
    }
    return null;
  }

  Future<Uint8List?> getPhoto(String phoneNumber) async {
    Uint8List? data;
    data = await firebaseProvider.getImageForNumber(phoneNumber);
    if (data != null) return data;
    Contact? contact = findContactByPhoneNumber(phoneNumber);
    if (contact == null) return null;
    data = contact.photoOrThumbnail;
    return data;
  }
}

class AvailableContact {
  AvailableContact(this.contact, this.phoneIndex, this.token);
  final Contact contact;
  final int phoneIndex;
  final String token;
}
