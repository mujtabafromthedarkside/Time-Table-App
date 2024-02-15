import 'package:flutter/material.dart';
import 'package:timetable/screens/LandingPage.dart';

class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xffA7D5FF),
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.people_alt),
            title: Text("About Us"),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return LandingPage(); //Profile()
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.policy),
            title: Text("Privacy Policy"),
            onTap: (){},
          ),
        ],
      ),
    );
  }
}
