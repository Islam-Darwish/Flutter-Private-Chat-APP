import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:private_chat/providers/firebase_provider.dart';
import 'package:private_chat/screens/loading_screen.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseProvider firebaseProvider = Provider.of<FirebaseProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.1,
              ),
              ProfileImage(
                width: constraints.maxWidth,
                firebaseProvider: firebaseProvider,
              ),
              SizedBox(
                height: constraints.maxHeight * 0.02,
              ),
              Text(
                (firebaseProvider.firebaseUser!.displayName != null &&
                        firebaseProvider.firebaseUser!.displayName!.isNotEmpty)
                    ? firebaseProvider.firebaseUser!.displayName!
                    : firebaseProvider.firebaseUser!.phoneNumber ?? '',
                style: Theme.of(context).textTheme.headline6,
              ),
              Expanded(child: Container()),
              MaterialButton(
                onPressed: () async {
                  await firebaseProvider.signOut();
                  Navigator.of(context)
                      .pushReplacementNamed(LoadingScreen.routeName);
                },
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).errorColor,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({required this.width, required this.firebaseProvider});
  final double width;
  final FirebaseProvider firebaseProvider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => BottomSheet(
            onClosing: () {},
            builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MaterialButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final _picker = ImagePicker();
                    final pickedFile =
                        await _picker.getImage(source: ImageSource.gallery);
                    if (pickedFile == null) return;
                    final croppedImage = await ImageCropper.cropImage(
                        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                        sourcePath: pickedFile.path);
                    if (croppedImage == null) return;
                    showDialog(
                      context: context,
                      builder: (_) => WillPopScope(
                        onWillPop: () async {
                          return false;
                        },
                        child: JumpingDotsProgressIndicator(
                          fontSize: 72,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      barrierDismissible: false,
                    );
                    await firebaseProvider.uploadImageProfile(croppedImage);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: width,
                    alignment: Alignment.center,
                    child: Text(
                      'Change',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
                if (firebaseProvider.firebaseUser!.photoURL != null &&
                    firebaseProvider.firebaseUser!.photoURL!.isNotEmpty &&
                    firebaseProvider.firebaseUser!.photoURL != 'deleted')
                  Divider(),
                if (firebaseProvider.firebaseUser!.photoURL != null &&
                    firebaseProvider.firebaseUser!.photoURL!.isNotEmpty &&
                    firebaseProvider.firebaseUser!.photoURL != 'deleted')
                  MaterialButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => WillPopScope(
                          onWillPop: () async {
                            return false;
                          },
                          child: JumpingDotsProgressIndicator(
                            fontSize: 72,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      );
                      await firebaseProvider.removeProfileImage();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: width,
                      alignment: Alignment.center,
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      child: CircleAvatar(
        radius: width * 0.3,
        child: Icon(
          Icons.person,
          size: width * 0.5,
        ),
        foregroundImage: (firebaseProvider.firebaseUser!.photoURL != null &&
                firebaseProvider.firebaseUser!.photoURL!.isNotEmpty &&
                firebaseProvider.firebaseUser!.photoURL != 'deleted')
            ? Image.network(
                firebaseProvider.firebaseUser!.photoURL!,
              ).image
            : null,
      ),
    );
  }
}
