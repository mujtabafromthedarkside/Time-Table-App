import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TimetableItem {
  String text;
  Color? color;

  TimetableItem(this.text, this.color);
}

class TimetableItem2 {
  String text;
  Color? color;
  int idx;
  int size;

  TimetableItem2(this.text, this.color, this.size, this.idx);
}

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  
  Future<void> _showTextInputDialog(BuildContext context, TimetableItem item) async {
    TextEditingController textController1 = TextEditingController();
    textController1.text = item.text.split("\n")[0];
    TextEditingController textController2 = TextEditingController();
    textController2.text = item.text.split("\n").length > 1 ? item.text.split("\n")[1] : "";
    Color currentColor = Color(0xFF123123); // Initial color

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Enter Details'),
          content: Container(
            height: 275,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController1,
                  decoration: InputDecoration(labelText: 'Enter Course:', hintText: 'For example, ES324'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: textController2,
                  decoration: InputDecoration(labelText: 'Enter Venue:', hintText: 'For example, ACB MLH'),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: 
                //   // MaterialPicker(
                //   //   pickerColor: currentColor,
                //   //   onColorChanged: (Color color) {
                //   //     currentColor = color;
                //   //   },
                //   //   enableLabel: true,
                //   // ),
                // ),
          
                  Center(
                    child: BlockPicker(
                        pickerColor: currentColor,
                        onColorChanged: (Color color) {
                          currentColor = color;
                        },
                        availableColors: const [
                          Color.fromARGB(255, 255, 159, 152), Color.fromARGB(255, 242, 86, 75), Colors.red, Color.fromARGB(255, 197, 13, 0), 
                          Color.fromARGB(255, 157, 245, 160), Color.fromARGB(255, 80, 236, 85), Color.fromARGB(255, 71, 189, 75), Color.fromARGB(255, 28, 138, 31), 
                          Color.fromARGB(255, 157, 207, 249), Color.fromARGB(255, 82, 160, 225), Colors.blue, Color.fromARGB(255, 11, 108, 188), 
                          Color.fromARGB(255, 255, 247, 176), Color.fromARGB(255, 255, 241, 118), Color.fromARGB(255, 255, 237, 72), Color.fromARGB(255, 255, 230, 0), 
                          Color.fromARGB(255, 255, 216, 156), Color.fromARGB(255, 255, 192, 96), Color.fromARGB(255, 255, 177, 60), Colors.orange, 
                          Color.fromARGB(255, 241, 160, 255), Color.fromARGB(255, 206, 68, 231), Color.fromARGB(255, 178, 42, 202), Color.fromARGB(255, 159, 1, 187), Color.fromARGB(255, 167, 11, 194), 
                          Colors.pink,
                          Colors.teal,
                          Colors.cyan,
                          Colors.brown,
                          Colors.grey,
                          Colors.black,
                        ],
                    ),
                  ),
          
                //   ColorPicker(
                //   pickerColor: currentColor,
                //   onColorChanged: (Color color) {
                //     currentColor = color;
                //   },
                //   enableAlpha: false,
                //   showLabel: true,
                //   pickerAreaHeightPercent: 0.8,
                // ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle the input and close the dialog
                setState(() {
                  // don't add \n if venue empty, to keep text vertically centered
                  item.text = textController1.text.toUpperCase() + (textController2.text == "" ? "" : "\n" + textController2.text.toUpperCase());

                  // if user selected a color
                  if(currentColor != Color(0xFF123123)){
                    item.color = currentColor;
                  }
                });
                print('Typed text 1: ${textController1.text}');
                print('Typed text 2: ${textController2.text}');
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String? selectedBatch = 'Choose your batch';
  String? selectedFaculty = 'Choose your faculty';

  final List<TimetableItem2> overlayData = [
    TimetableItem2('wow', Colors.blue, 2, 2),
    TimetableItem2('wow', Colors.red, 2, 2),
    TimetableItem2('wow', Colors.blue, 2, 2),
  ];

  final List<int> overlayIndices = [2, 5, 7];

    final List<TimetableItem> timetableData = [
    TimetableItem('', Colors.white),
    TimetableItem('8:00 - 8:30', Colors.black12),
    TimetableItem('8:30 - 9:00', Colors.black12),
    TimetableItem('9:00 - 9:30', Colors.black12),
    TimetableItem('9:30 - 10:00', Colors.black12),
    TimetableItem('10:00 - 10:30', Colors.black12),
    TimetableItem('10:30 - 11:00', Colors.black12),
    TimetableItem('11:00 - 11:30', Colors.black12),
    TimetableItem('11:30 - 12:00', Colors.black12),
    TimetableItem('12:00 - 12:30', Colors.black12),
    TimetableItem('12:30 - 1:00', Colors.black12),
    TimetableItem('1:00 - 1:30', Colors.black12),
    TimetableItem('1:30 - 2:00', Colors.black12),
    TimetableItem('2:00 - 2:30', Colors.black12),
    TimetableItem('2:30 - 3:00', Colors.black12),
    TimetableItem('Mon', Colors.black45),
    TimetableItem('ES341\nACB MLH', Colors.red),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('ES341\nACB MLH', Colors.red),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Tue', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('ES341\nACB MLH', Colors.red),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('ES341\nACB MLH', Colors.red),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Wed', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Thu', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Fri', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Sat', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('Sun', Colors.black45),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    TimetableItem('', Colors.white),
    // Add more items as needed
  ];

  final int gridRows = 8;
  final int gridColumns = 15;
  bool editButtonPressed = false;
  bool resizeButtonPressed = false;
  bool copyButtonPressed = false;
  int copyIndex = -1;

  int toRowMajor(int index){
    return index%gridRows * gridColumns + index~/gridRows;
    // rows passed * rows + columns passed
  }

  int toColumnMajor(int index){
    return index%gridColumns * gridRows + index~/gridColumns;
    // columns passed * rows + rows passed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Time Table"),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Container(
                    constraints: BoxConstraints(
                      maxWidth: 180,
                    ),
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DropdownButton<String>(
                        selectedItemBuilder: (BuildContext context) {
                          return <String>['Choose your batch', '33', '32', '31', '30', '29'].map((String value) {
                            // return Center(
                            //   child: Text(
                            //     value,
                            //     // textAlign: TextAlign.center,
                            //   )
                            // );
                            return SizedBox(width: 152, child: Center(child: Text(value, style: TextStyle(color: Colors.black))));
                          }).toList();
                        },
                        items: <String>['Choose your batch', '33', '32', '31', '30', '29'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                                // textAlign: TextAlign.center,
                              )
                            ),
                          );
                        }).toList(),
                        // value: selectedOption,
                        // onChanged: (newValue) {
                        //   setState(() {
                        //     selectedOption = newValue;
                        //   });

                        // },
                        onChanged: (String? value) => setState(
                            () {
                              selectedBatch = value ?? "";
                          }
                        ),
                        value: selectedBatch,
                        // onChanged: (_){},
                        // hint: const Text('Choose your batch'),

                    
                        icon: const Icon(Icons.arrow_downward), // Custom icon
                        iconSize: 20, // Set icon size
                        elevation: 0, // Dropdown menu elevation
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                        dropdownColor: Colors.blue,
                      ),
                    ),
                  ),
             
              Container(
                    constraints: BoxConstraints(
                      maxWidth: 180,
                    ),
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.blue, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DropdownButton<String>(
                        selectedItemBuilder: (BuildContext context) {
                          return <String>['Choose your faculty', 'AI', 'CS', 'ME'].map((String value) {
                            return SizedBox(width: 152, child: Center(child: Text(value, style: TextStyle(color: Colors.black))));
                          }).toList();
                        },
                        items: <String>['Choose your faculty', 'AI', 'CS', 'ME'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                                // textAlign: TextAlign.center,
                              )
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) => setState(
                            () {
                              selectedFaculty = value ?? "";
                          }
                        ),
                        value: selectedFaculty,                    
                        icon: const Icon(Icons.arrow_downward), // Custom icon
                        iconSize: 20, // Set icon size
                        elevation: 0, // Dropdown menu elevation
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                        dropdownColor: Colors.blue,
                      ),
                    ),
                  ),
                 ],
               ),
             ),

          Expanded(
            child: 
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align horizontally to the start (left)
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.blue,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.red,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.purple,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.yellow,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.orange,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.purple,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.red,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.blue,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.purple,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.red,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.blue,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.purple,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.red,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                color: Colors.blue,
                                child: Center(
                                  child: Text("HELLO")
                                )
                              )
                            ],
                          ),
                        ],
                      ),
                  )
                )
              )

            // Container(
            //   child: 
            //   ListView(
            //     scrollDirection: Axis.horizontal,
            //     children: <Widget>[
            //       ListView(
            //         children: <Widget>[
            //         SizedBox(
            //           width: 400,
            //           height: 100,
            //           child: Container(
            //                   color: Colors.blue,
            //           ),
            //         ),
            //         Container(
            //                 width: 50.0,
            //                 height: 50.0,
            //                 color: Colors.red,
            //         ),
            //         ]
            //       ),
            //     ]
            //   ),
            // ),
        ),

             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0,40,0,20),
                  decoration: BoxDecoration(
                    color: editButtonPressed ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                       backgroundColor: editButtonPressed ? Colors.red : Colors.blue,
                       foregroundColor: Colors.black,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                     ),
                     onPressed: () {
                      setState(() {
                        if(copyButtonPressed || resizeButtonPressed){}
                        else{
                          editButtonPressed = !editButtonPressed;
                        }
                      });
                     },
                     child: Text(
                       editButtonPressed ? "Cancel" : "Edit",
                       style: TextStyle(
                         fontSize: 20,
                         fontFamily: 'Roboto',
                       ),
                     ),
                   ),
                 ),

                Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0,40,0,20),
                  decoration: BoxDecoration(
                    color: resizeButtonPressed ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                       backgroundColor: resizeButtonPressed ? Colors.red : Colors.blue,
                       foregroundColor: Colors.black,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                     ),
                     onPressed: () {
                      setState(() {
                        if(copyButtonPressed || editButtonPressed){}
                        else {
                          resizeButtonPressed = !resizeButtonPressed; 
                        }
                      });
                     },
                     child: Text(
                       resizeButtonPressed ? "Cancel" : "Resize",
                       style: TextStyle(
                         fontSize: 20,
                         fontFamily: 'Roboto',
                       ),
                     ),
                   ),
                 ),

                 Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0,40,0,20),
                  decoration: BoxDecoration(
                    color: copyButtonPressed ? Colors.red : Colors.blue,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                       backgroundColor: copyButtonPressed ? Colors.red : Colors.blue,
                       foregroundColor: Colors.black,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                     ),
                     onPressed: () {
                      setState(() {
                        print("$editButtonPressed $resizeButtonPressed $copyButtonPressed");
                        if(editButtonPressed || resizeButtonPressed){}
                        else {
                          copyButtonPressed = !copyButtonPressed;
                          if(copyButtonPressed == false){
                            copyIndex = -1;
                          }
                        }
                      });
                     },
                     child: Text(
                       copyButtonPressed ? "Cancel" : "Copy",
                       style: TextStyle(
                         fontSize: 20,
                         fontFamily: 'Roboto',
                       ),
                     ),
                   ),
                 ),
               ],
             ),
          ],
        ),
      ),
    );
  }
}