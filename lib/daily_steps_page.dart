import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_steps/main.dart';
import 'package:daily_steps/Pages/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

int localSecondTime = 0;

class DailyStepsPage extends StatefulWidget {
  @override
  _DailyStepsPageState createState() => _DailyStepsPageState();
}

class _DailyStepsPageState extends State<DailyStepsPage> {
  String userId = FirebaseAuth.instance.currentUser.uid;
  Pedometer _pedometer; //init pedometer
  StreamSubscription<int> _subscription; //we need sub to get the stream value
  Box<int> stepsBox = Hive.box('steps');
  //hive is a kind of localstorage similar to sqlite
  Box<int> sleepBox = Hive.box('sleepbox');

  Box<String> gotoSleepBox = Hive.box('gotoSleepBox');
  Box<String> wakeupBox = Hive.box('wakeupBox');

  int todaySteps; //will save todays steps
  String _km = "Unknown";
  String _calories = "Unknown";
  double _kmx;
  double burnedx;
  double _numerox; //stepcount
  double _convert;
  String sleepTime = globalRawTime;
  int dbSleepTime = 0;

  final Color carbonBlack = Color(0xff1a1a1a);
  final Color bgColor = Color(0xFF161616);

  @override
  initState() {
    super.initState();
    setState(() {});
    getDBSleep();
    startListening();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void startListening() {
    _pedometer = Pedometer();
    _subscription = _pedometer.pedometerStream.listen(
      getTodaySteps,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onDone() => print("Finished pedometer tracking");
  void _onError(error) => print("Flutter Pedometer Error: $error");

  Future<int> getTodaySteps(int value) async {
    //print(value);
    int savedStepsCountKey = 999999;
    int savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;
    if (value < savedStepsCount) {
      // Upon device reboot, pedometer resets. When this happens, the saved counter must be reset as well.
      savedStepsCount = 0;
      // persist this value using a package of your choice here
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }

    // load the last day saved using a package of your choice here
    int lastDaySavedKey = 888888;
    int lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    // When the day changes, reset the daily steps count
    // and Update the last day saved as the day changes.
    if (lastDaySaved < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = value;

      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }

    setState(() {
      todaySteps = value - savedStepsCount;
    });
    stepsBox.put(todayDayNo, todaySteps);

    var dist = todaySteps;
    //we pass the integer value of daily steps to a variable called dist

    double y = (dist + .0);
    //we convert it to double

    setState(() {
      _numerox = y;
      //we pass it to a state to be captured and converted to double
    });

    var long3 = (_numerox);
    long3 = num.parse(y.toStringAsFixed(2));
    var long4 = (long3 / 10000);

    int decimals = 1;
    int fac = pow(10, decimals);
    double d = long4;
    d = (d * fac).round() / fac;

    getDistanceRun(_numerox);

    setState(() {
      _convert = d;
    });
    return todaySteps; // this is your daily steps value.
  }

  //function to determine the distance run in kilometers using number of steps
  void getDistanceRun(double _numerox) {
    var distance = ((_numerox * 78) / 100000);
    distance = num.parse(distance.toStringAsFixed(2)); //two decimal places
    var distancekmx = distance * 34;
    distancekmx = num.parse(distancekmx.toStringAsFixed(2));
    setState(() {
      _km = "$distance";
      print('dist: ' + _km);
    });
    setState(() {
      _kmx = num.parse(distancekmx.toStringAsFixed(2));
    });
  }

  //function to determine the calories burned in kilometers using number of steps
  void getBurnedRun() {
    setState(() {
      var calories = _kmx; //two decimal places
      _calories = "$calories";
      print('cal: ' + _calories);
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  getDBSleep() {
    print('fetching sleeptime from db');
    FirebaseFirestore.instance
        .collection('bracuFitnessData')
        .doc(userId)
        .collection(userId)
        .doc(Jiffy(DateTime.now()).format('dd-MM-yyyy'))
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        //print('document er data');

        if (documentSnapshot.data()['sleepTime'] == null) {
          //print('sleepTime not available');
          return dbSleepTime;
        } else {
          // print('sleepTime available');
          dbSleepTime = await documentSnapshot.data()['sleepTime'];
          sleepBox.put(hiveSleepKey, dbSleepTime);
          return dbSleepTime;
        }
      } else {
        return 0;
      }
    });
  }

  getHiveValue() {
    return sleepBox.get(hiveSleepKey, defaultValue: 0);
  }

  getEarliestSleepTime() {
    return gotoSleepBox.get(hiveSleepKey, defaultValue: "0");
  }

  getLatestWakupTime(){
    return wakeupBox.get(hiveSleepKey, defaultValue: "0");
  }

  int getAddedSleep(int globalSecondTimeParam, int dbSleepTime) {
    int sum = dbSleepTime + globalSecondTimeParam;
    sleepBox.put(hiveSleepKey, sum);
    localSecondTime = globalSecondTime;
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now();

    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 01);

    if (date.compareTo(endTime) > 0) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('bracuFitnessData')
          .doc(userId)
          .collection(userId)
          .doc(Jiffy(DateTime.now()).format('dd-MM-yyyy'));
      documentReference.set({
        'Steps': '$todaySteps',
        'calories': '$_calories',
        'date': Jiffy(DateTime.now()).format('dd MMM yyyy'),
        'distance': '$_km',
        'Earliest Sleeping Time': getEarliestSleepTime(),
        'Last Waking Time': getLatestWakupTime(),
        'sleepTime':
            getAddedSleep(globalSecondTime - localSecondTime, getHiveValue())
      });

      getDBSleep();
    }

    getBurnedRun();
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Mental Health Support",
          style: GoogleFonts.darkerGrotesque(fontSize: 32),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20),
              child: CircularPercentIndicator(
                radius: 200.0,
                lineWidth: 13.0,
                animation: true,
                center: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          FontAwesomeIcons.walking,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        //color: Colors.orange,
                        child: Text(
                          '$todaySteps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                percent: 0.217,
                //percent: _convert,
                footer: Text(
                  "Steps:  $todaySteps",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Colors.purple,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.purpleAccent,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 25),
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 80.0,
                        width: 80.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/distance.svg',
                              color: Colors.white,
                              height: 50,
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "$_km Km",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: carbonBlack,
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 80.0,
                        width: 80.0,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/images/burn.svg',
                              color: Colors.white,
                              height: 50,
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: Text(
                                "$_calories Cal",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: carbonBlack,
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 25),
                    child: Card(
                      elevation: 10,
                      child: Container(
                        height: 80.0,
                        width: 80.0,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/images/running.svg',
                              color: Colors.white,
                              height: 50,
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: Text(
                                "$todaySteps Steps",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      color: carbonBlack,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 100),
              child: RaisedButton(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                color: Colors.purpleAccent,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 35, top: 30),
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => History(
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
