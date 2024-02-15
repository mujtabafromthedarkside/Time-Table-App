import 'package:flutter/material.dart';
// import 'package:timetable/screens/TimeTablePageOld.dart';
import 'package:timetable/screens/timetable/TimeTablePageNew.dart';
import 'dart:convert';
import '../config/config.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login>{
  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool passToggle = true;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/background1.png"),
            fit: BoxFit.cover,
          ),
          color: backgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image(image: AssetImage(
              //   "lib/assets/gikilogo.png",
              // ),
              //   height: 100,
              //   width: 100,
              // ),
              SizedBox(height: 160),
              Text(
                'Admin he hou na?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Form(
                    key: _formfield,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Color(0xffE9E9E9),
                          ),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter email";
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: passController,
                          obscureText: passToggle,
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xffE9E9E9),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: InkWell(
                                onTap: (){
                                  setState(() {
                                    passToggle = !passToggle;
                                  });
                                },
                                child: Icon(passToggle ? Icons.visibility : Icons.visibility_off),
                              )
                          ),
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter password";
                            }
                          },
                        ),
                        SizedBox(height: 60),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimeTablePage(),
                              ),
                            );
                          },
                          child: Text('login', style: TextStyle(fontSize: 24, color: Colors.white), ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)
                            ),
                            backgroundColor: Color(0xFFE9A21A),
                            padding: EdgeInsets.only(left: 50, top: 12, right: 50, bottom: 12),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}