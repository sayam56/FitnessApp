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
/* Future<String> savedSleep;
String todaySleepTime;
Box<String> sleepBox; */

final StopWatchTimer _stopWatchTimer = StopWatchTimer(
  isLapHours: true,
/*     onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'), */
);

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
/* void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  print("this is headless SAYAM");
  // Do your work here...
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
  );

  _stopWatchTimer.rawTime.listen((value) {
    globalRawTime = StopWatchTimer.getDisplayTime(value);
  });

  _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));

  //this is from the background. should be all good
  if ("${await isLockScreen()}" == 'false') {
    print('phone open, is lock screen: ${await isLockScreen()}');
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
  }

  if ("${await isLockScreen()}" == 'true') {
    print('phone locked, is lock screen: ${await isLockScreen()}');
    if (_stopWatchTimer.isRunning == false) {
      print("timer was not running, starting now");
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }
  }

  BackgroundFetch.finish(taskId);
} */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
/*   await Hive.openBox<String>('sleep'); */
  runApp(MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}
//firebase auth

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  User firebaseUser = FirebaseAuth.instance.currentUser;
  Widget firstWidget;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _stopWatchTimer.rawTime.listen((value) {
      globalRawTime = StopWatchTimer.getDisplayTime(value);
    });

    _stopWatchTimer.secondTime.listen((value) {
      globalSecondTime = value;
      print('second Time : ' + '$value');
    });

/*     sleepBox = Hive.box('sleep'); */

/*     //save sleep here
    savedSleep=getSavedSleepData(globalRawTime); */

    /// Can be set preset time. This case is "00:01.23".
    // _stopWatchTimer.setPresetTime(mSec: 1234);
    initPlatformState();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print('app inactive, is lock screen: ${await isLockScreen()}');

      if ("${await isLockScreen()}" == 'true') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
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

/*   Future<String> getSavedSleepData(String globalRawStopwatchData) async {
    String sleepKey = '99999999';
    String savedSleepCount =
        sleepBox.get(sleepKey, defaultValue: '00:00:00:00');

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;

    if (globalRawStopwatchData.compareTo(savedSleepCount) <= 0) {
      //if the current sleeptime is less than the saved sleep this means no sleeptime has been recorded yet
      savedSleepCount = '00:00:00:00';

      // persisting this
      sleepBox.put(sleepKey, savedSleepCount);
    }

    //this should be the resetting block :3 ---------------------------------------------------------------------------------------

    /* // load the last day saved using a package of your choice here
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
    } */

    setState(() {
      String globalRawTimeWithoutExtra =
          globalRawStopwatchData.replaceAll(':', '');
      String savedSleepTimeWithoutExtra = savedSleepCount.replaceAll(':', '');
      int tempSleepTime = int.parse(globalRawTimeWithoutExtra) -
          int.parse(savedSleepTimeWithoutExtra);
      todaySleepTime = tempSleepTime.toString();
    });

    print('----------------------------------------------------------------');
    print(todaySleepTime);

    sleepBox.put(todayDayNo, todaySleepTime);

    return todaySleepTime;
  } */

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
      print("[BackgroundFetch] Event received $taskId");

      print("This is from the future InitPlatform shyt");

      //this is from the background. should be all good
      if ("${await isLockScreen()}" == 'true') {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
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
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

/*  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  } */

  @override
  Widget build(BuildContext context) {
    if (firebaseUser != null) {
      print('logged in');
      print(firebaseUser.uid);
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
