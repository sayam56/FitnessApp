import 'package:background_fetch/background_fetch.dart';
import 'package:daily_steps/Pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:daily_steps/daily_steps_page.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

String globalRawTime = '00:00:00:00';
int globalSecondTime = 0;
int oldVal = 0;

final StopWatchTimer _stopWatchTimer = StopWatchTimer(
  isLapHours: true,
);

final startSleepTimeCountMark = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 00);

final stopSleepTimeCountMark = DateTime(
    DateTime.now().year, DateTime.now().month, DateTime.now().day, 08, 00);

String hiveSleepKey = Jiffy(DateTime.now()).format('dd-MM-yyyy');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
  await Hive.openBox<int>('sleepbox');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  User firebaseUser = FirebaseAuth.instance.currentUser;
  Widget firstWidget;
  int _status = 0;
  List<DateTime> _events = [];
  Box<int> sleepBox = Hive.box('sleepbox');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _stopWatchTimer.rawTime.listen((value) {
      globalRawTime = StopWatchTimer.getDisplayTime(value);
    });

    _stopWatchTimer.secondTime.listen((value) {
      globalSecondTime = value;
      //updateHive(value);

      print('second Time : ' + '$value');
    });

    initPlatformState();
  }

  // updateHive(int sleepVal) {
  //   int previousHiveValue = sleepBox.get(hiveSleepKey, defaultValue: 0);
  //   sleepBox.put(hiveSleepKey, sleepVal + previousHiveValue - oldVal);
  //   oldVal = sleepVal;
  // }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  bool getSleepCountStatus() {
    var now = new DateTime.now();

    if (now.compareTo(startSleepTimeCountMark) > 0 ||
        now.compareTo(stopSleepTimeCountMark) < 0) {
      return true;
    }

    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print('app inactive, is lock screen: ${await isLockScreen()}');

      if ("${await isLockScreen()}" == 'true') {
        if (getSleepCountStatus() == true) {
          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
        }
      }
      if ("${await isLockScreen()}" == 'false') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      }
    }
    if (state == AppLifecycleState.resumed) {
      print('app resumed, is lock screen: ${await isLockScreen()}');

      if ("${await isLockScreen()}" == 'true') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      }
      if ("${await isLockScreen()}" == 'false') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      }
    }
    if (state == AppLifecycleState.paused) {
      print('app paused, is lock screen: ${await isLockScreen()}');
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      //print("[BackgroundFetch] Event received $taskId");

      //print("This is from the future InitPlatform");

      //this is from the background. should be all good
      if ("${await isLockScreen()}" == 'true') {
        if (getSleepCountStatus() == true) {
          _stopWatchTimer.onExecute.add(StopWatchExecute.start);
        }
      }
      if ("${await isLockScreen()}" == 'false') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      }

      setState(() {
        _events.insert(0, new DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      //print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    //print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseUser != null) {
      print('logged in');
      //print(firebaseUser.uid);
      firstWidget = DailyStepsPage();
    } else {
      print('NOT logged in');
      firstWidget = LoginPage();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Steps',
      home: firstWidget,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        textTheme: GoogleFonts.darkerGrotesqueTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.darkerGrotesqueTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}
