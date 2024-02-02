import 'package:flutter/material.dart';
import 'package:timetable/config/config.dart';
import 'package:timetable/screens/login.dart';

import '../config/API_funcs.dart';
import 'TimeTablePageNew.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/LandingPage_background.png"),
              fit: BoxFit.cover,
            ),
          ),
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.80),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  fetchData(context);
                },
                child: Text('dekhte hain', style: TextStyle(fontSize: 24, color: Colors.white), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  backgroundColor: Color(0xFF357C93),
                  padding: EdgeInsets.only(left: 50, top: 12, right: 50, bottom: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchData(BuildContext context) async {
    try {
      // String url = URL + "add_timetable";
      // print(url);
      // final dataToSend = {"faculty": "AI31",
      //   "day": "friday",
      //   "color": "#FF5733",
      //   "start_time": "9:00",
      //   "end_time": "12:00",
      //   "venue":"LH3 FCSE",
      //   "subject":"CS221"};
      // final jsonData = await getterAPIWithDataPOST(url, data: dataToSend);

      // print(jsonData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimeTablePage(),
        ),
      );
    } catch (e) {
      // Handle any errors that occur during the API requests.
      print('Error: $e');
    }
  }
}
