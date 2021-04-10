import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';

String todayDate = Jiffy(DateTime.now()).format('dd MMM yyyy');

class History extends StatefulWidget {
  final String userId;
  History({this.userId});
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1a1a1a),
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.black,
        elevation: 4,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bracuFitnessData')
            .doc(widget.userId)
            .collection(widget.userId)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) return Text(' NO HISTORY UPLOADED YET');
          return ListView(
            children: snapshot.data.documents.map<Widget>((document) {
              String dateVal = document['date'];
              if (dateVal != todayDate) {
                final now = Duration(seconds:document['sleepTime']);
                print(dateVal);
                print(todayDate);
                return Container(
                  height: 80,
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.black,
                        ),
                        child: Text(document['date'],
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.black,
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            SvgPicture.asset(
                              'assets/images/running.svg',
                              color: Colors.white,
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(document['Steps'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.black,
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            SvgPicture.asset(
                              'assets/images/distance.svg',
                              color: Colors.white,
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(document['distance'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.black,
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            SvgPicture.asset(
                              'assets/images/burn.svg',
                              color: Colors.white,
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(document['calories'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          //color: Colors.black,
                        ),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            SvgPicture.asset(
                              'assets/images/sleep.svg',
                              color: Colors.white,
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('${_printDuration(now)}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ],
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  height: 0,
                );
              }
            }).toList(),
          );
        },
      ),
    );
  }
}
