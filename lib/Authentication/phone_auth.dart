import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import '../daily_steps_page.dart';

/* class PhoneAuth extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _phoneAuthController = TextEditingController();
  final _otpcontroller = TextEditingController();

  Future<bool> loginUser(String phoneNumber, BuildContext context) async {
    await Firebase.initializeApp();
    FirebaseAuth _authPhone = FirebaseAuth.instance;

    _authPhone.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          //this gets called only when the verification is done by codeAutoRetrievalTimeout Method auto
          UserCredential result =
              await _authPhone.signInWithCredential(credential);
          User user = result.user;

          if (user != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return DailyStepsPage();
            }));
          } else {
            print('ERROR');
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          //print(exception);
        },
        codeSent: (String verificationId, [int forceResendToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text('Enter The OTP Code'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _otpcontroller,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Confirm'),
                      textColor: Colors.white,
                      color: Colors.brown[200],
                      onPressed: () async {
                        final otp = _otpcontroller.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId, smsCode: otp);
                        UserCredential result =
                            await _authPhone.signInWithCredential(credential);
                        User user = result.user;

                        if (user != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DailyStepsPage();
                          }));
                        } else {
                          print('Error');
                        }
                      },
                    ),
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  //textFields
  String phone = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation:
            0.0, //removes the drop shadow cause it is not elevated anymore
        title: Text('Phone Number Login'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _phoneAuthController,
                /* inputFormatters: [FilteringTextInputFormatter.digitsOnly], */
                /* keyboardType: TextInputType.number, */
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter A Phone Number';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                color: Colors.pink[400],
                child: Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  final phone = _phoneAuthController.text.trim();
                  print(phone);
                  loginUser(phone, context);
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                error,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Phone extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

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
                title: Text('Give the code'),
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
                      child: Text('Confim'),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
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
                      }),
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
      backgroundColor: Colors.black26,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
        title: Text(
          'Sing In',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Type Text Here...',
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  cursorColor: Colors.white,
                  controller: _phoneController,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child:
                        Text('Sing In', style: TextStyle(color: Colors.white)),
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
