import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../daily_steps_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Phone extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final Color carbonBlack = Color(0xff1a1a1a);

  Future<bool> loginUser(String phone, BuildContext context) async {
    await Firebase.initializeApp();
    print(phone.toString() + "f1");
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          print(phone.toString() + "f2");
          Navigator.of(context).pop();
          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;
          if (user != null) {
            print(phone.toString() + "f3");
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DailyStepsPage()));
          } else {
            print('Error');
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(phone.toString() + "f4");
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                backgroundColor: carbonBlack,
                title: Text(
                  'Enter The Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    )
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Confirm'),
                    textColor: Colors.white,
                    color: Colors.purpleAccent,
                    onPressed: () async {
                      final code = _codeController.text.trim();
                      AuthCredential credential = PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: code);
                      UserCredential result =
                          await _auth.signInWithCredential(credential);
                      User user = result.user;
                      if (user != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DailyStepsPage()));
                      } else {
                        print('Error');
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  final Function toggleView;
  Phone({this.toggleView});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: carbonBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Sign In With OTP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
          color: carbonBlack,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Phone Number (With Country Code)',
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: carbonBlack,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.purpleAccent,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  cursorColor: Colors.white,
                  controller: _phoneController,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: 150,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.purpleAccent),
                    ),
                    color: carbonBlack,
                    elevation: 2,
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        SvgPicture.asset(
                          'assets/images/otp.svg',
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Get OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    onPressed: () {
                      final phone = _phoneController.text.trim();
                      print(phone.toString());
                      loginUser(phone, context);
                      print(phone.toString());
                    },
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          )),
    );
  }
}
