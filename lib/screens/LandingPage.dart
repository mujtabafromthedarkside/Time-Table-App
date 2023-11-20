import 'package:flutter/material.dart';
import 'package:timetable/config/strings.dart';

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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingPage(),
                    ),
                  );
                },
                child: Text(LandingPageContinueButton, style: TextStyle(fontSize: 24),),
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
}
