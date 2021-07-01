import 'package:flutter/material.dart';
import 'package:private_chat/screens/main_screen/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../providers/firebase_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber = '';
  String countryCode = '+20';
  String code = '';
  bool sendCodeEnabled = false;
  bool phoneTextFieldEnabled = true;
  bool verifyCodeEnabled = false;
  bool showVerify = false;
  String sendCode = 'Send';
  Future<void> requistCode(BuildContext context) async {
    setState(() {
      sendCodeEnabled = false;
      phoneTextFieldEnabled = false;
    });
    //login
    String normalizeNumber = countryCode + phoneNumber;

    FirebaseProvider firebaseProvider =
        Provider.of<FirebaseProvider>(context, listen: false);
    String res = await firebaseProvider.signInWithPhoneNumber(normalizeNumber);
    if (res.isEmpty) {
      //reCAPTCHA
      //show otp field
      try {
        showVerify = true;
        setState(() {});
      } catch (e) {}
    } else if (res == 'codeSent') {
      //show otp field
      try {
        showVerify = true;
        setState(() {});
      } catch (e) {}
    } else {
      //error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    }
    for (int i = 30; i >= 1; i--) {
      try {
        sendCode = 'Send ($i)';
        setState(() {});
      } catch (e) {}
      await Future.delayed(Duration(seconds: 1));
    }
    try {
      sendCode = 'Send';
      sendCodeEnabled = true;
      phoneTextFieldEnabled = true;
      setState(() {});
    } catch (e) {}
  }

  Future<bool> verifyCode(BuildContext context) async {
    //verify
    try {
      verifyCodeEnabled = false;
      setState(() {});
    } catch (e) {}
    FirebaseProvider firebaseProvider =
        Provider.of<FirebaseProvider>(context, listen: false);
    bool res = await firebaseProvider.sendOTP(code);
    if (res) {
      firebaseProvider.registerMyToken();
      Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
    } else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error: The sms verification code used to create the phone auth credential is invalid. Please resend the verification code sms and be sure use the verification code provided by the user.')));
    try {
      verifyCodeEnabled = true;
      setState(() {});
    } catch (e) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth * 0.3,
                      child: CountryCodePicker(
                        textStyle: Theme.of(context).textTheme.bodyText2,
                        searchStyle: Theme.of(context).textTheme.bodyText2,
                        dialogTextStyle: Theme.of(context).textTheme.bodyText2,
                        onChanged: (value) =>
                            countryCode = value.dialCode ?? '+20',
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: countryCode,
                        favorite: ['+20', 'EG'],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * 0.5,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          helperText: '1234567890',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: Theme.of(context).textTheme.bodyText2,
                        enabled: phoneTextFieldEnabled,
                        maxLength: 15,
                        maxLines: 1,
                        minLines: 1,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          if (value.length < 8)
                            setState(() {
                              sendCodeEnabled = false;
                            });
                          else
                            setState(() {
                              sendCodeEnabled = true;
                            });
                          phoneNumber = value;
                        },
                      ),
                    ),
                    Container(
                      width: constraints.maxWidth * 0.2,
                      child: MaterialButton(
                        onPressed:
                            sendCodeEnabled ? () => requistCode(context) : null,
                        child: Text(
                          sendCode,
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: sendCodeEnabled
                                        ? Theme.of(context).accentColor
                                        : Colors.grey,
                                    fontSize: constraints.maxWidth * 0.04,
                                  ),
                        ),
                      ),
                    )
                  ],
                ),
                if (showVerify)
                  SizedBox(
                    height: 50,
                  ),
                if (showVerify)
                  Container(
                    width: constraints.maxWidth * 0.25,
                    child: TextFormField(
                      decoration: InputDecoration(hintText: 'Enter Code'),
                      style: Theme.of(context).textTheme.bodyText2,
                      onChanged: (value) {
                        if (value.length < 6)
                          setState(() {
                            verifyCodeEnabled = false;
                          });
                        else
                          setState(() {
                            verifyCodeEnabled = true;
                          });
                        code = value;
                      },
                    ),
                  ),
                if (showVerify)
                  SizedBox(
                    height: 20,
                  ),
                if (showVerify)
                  MaterialButton(
                    onPressed:
                        verifyCodeEnabled ? () => verifyCode(context) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Verify',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: verifyCodeEnabled
                                  ? Theme.of(context).accentColor
                                  : Colors.grey,
                              fontSize: constraints.maxWidth * 0.05,
                            ),
                      ),
                    ),
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
