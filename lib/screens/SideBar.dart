import 'package:flutter/material.dart';
import 'package:timetable/config/constants.dart';
import 'package:timetable/screens/LandingPage.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: LandingPageDarkBlue,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.people_alt,
              color: Colors.white,
            ),
            title: Text(
              "About Us",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return LandingPage(); //Profile()
              }));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.policy,
              color: Colors.white,
            ),
            title: Text("Privacy Policy", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
