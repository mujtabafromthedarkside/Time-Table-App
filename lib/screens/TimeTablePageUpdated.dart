import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

double TimeAxisUnitLength = 100;
double DayAxisUnitLength = 65;

double TimeAxisBreadth = 60;
double DayAxisBreadth = 100;

double TimeAxisUnitTime = 30;

Color DefaultGridColor = Color.fromARGB(255, 239, 173, 173);

class TimetableItem {
  String text;
  Color? color;

  TimetableItem(this.text, this.color);
}

class TimetableSlot {
  late int startTime;
  late int endTime;
  late int dayNumber;
  late double length;

  late String startTimeString;
  late String endTimeString;
  late String dayString;

  String course = "";
  String venue = "";
  String notes = "";

  Color? color = DefaultGridColor;

  TimetableSlot.FromStrings(this.startTimeString, this.endTimeString,
      this.dayString, this.course, this.venue, this.notes, this.color) {
    int startHours = int.parse(startTimeString.split(":")[0]);
    int startMinutes = int.parse(startTimeString.split(":")[1]);

    int endHours = int.parse(endTimeString.split(":")[0]);
    int endMinutes = int.parse(endTimeString.split(":")[1]);

    this.startTime = startHours * 60 + startMinutes;
    this.endTime = endHours * 60 + endMinutes;

    this.dayNumber = ["Mon", "Tue", "Wed", "Thu", "Fri"].indexOf(dayString);
    // FOR FUTURE, raise error if dayString not in ["Mon", "Tue", "Wed", "Thu", "Fri"]
    this.length =
        (this.endTime - this.startTime) / TimeAxisUnitTime * TimeAxisUnitLength;
  }

  TimetableSlot.FromValues(this.startTime, this.endTime, this.dayNumber) {
    // time ratio * unit length
    this.length =
        (this.endTime - this.startTime) / TimeAxisUnitTime * TimeAxisUnitLength;
  }
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
  Future<void> _showTextInputDialog(
      BuildContext context, TimetableItem item) async {
    TextEditingController textController1 = TextEditingController();
    textController1.text = item.text.split("\n")[0];
    TextEditingController textController2 = TextEditingController();
    textController2.text =
        item.text.split("\n").length > 1 ? item.text.split("\n")[1] : "";
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
                  decoration: InputDecoration(
                      labelText: 'Enter Course:',
                      hintText: 'For example, ES324'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: textController2,
                  decoration: InputDecoration(
                      labelText: 'Enter Venue:',
                      hintText: 'For example, ACB MLH'),
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
                        Color.fromARGB(255, 255, 159, 152),
                        Color.fromARGB(255, 242, 86, 75),
                        Colors.red,
                        Color.fromARGB(255, 197, 13, 0),
                        Color.fromARGB(255, 157, 245, 160),
                        Color.fromARGB(255, 80, 236, 85),
                        Color.fromARGB(255, 71, 189, 75),
                        Color.fromARGB(255, 28, 138, 31),
                        Color.fromARGB(255, 157, 207, 249),
                        Color.fromARGB(255, 82, 160, 225),
                        Colors.blue,
                        Color.fromARGB(255, 11, 108, 188),
                        Color.fromARGB(255, 255, 247, 176),
                        Color.fromARGB(255, 255, 241, 118),
                        Color.fromARGB(255, 255, 237, 72),
                        Color.fromARGB(255, 255, 230, 0),
                        Color.fromARGB(255, 255, 216, 156),
                        Color.fromARGB(255, 255, 192, 96),
                        Color.fromARGB(255, 255, 177, 60),
                        Colors.orange,
                        Color.fromARGB(255, 241, 160, 255),
                        Color.fromARGB(255, 206, 68, 231),
                        Color.fromARGB(255, 178, 42, 202),
                        Color.fromARGB(255, 159, 1, 187),
                        Color.fromARGB(255, 167, 11, 194),
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
                  item.text = textController1.text.toUpperCase() +
                      (textController2.text == ""
                          ? ""
                          : "\n" + textController2.text.toUpperCase());

                  // if user selected a color
                  if (currentColor != Color(0xFF123123)) {
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

  int toRowMajor(int index) {
    return index % gridRows * gridColumns + index ~/ gridRows;
    // rows passed * rows + columns passed
  }

  int toColumnMajor(int index) {
    return index % gridColumns * gridRows + index ~/ gridColumns;
    // columns passed * rows + rows passed
  }

  final List<String> texts = ['Text 1', 'Text 2'];
  final List<String> daysAxis = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  final List<String> timeAxis = [];
  final List<TimetableSlot> ContainersToPrint = [];
  final List<TimetableSlot> TimetableSlots = [
    // TimetableSlot.FromStrings("10:00", "11:00", "Mon", "ES341", "ACB MLH", "", Colors.red),
    TimetableSlot.FromStrings("8:00", "11:00", "Mon", "ES341",
        "ACB MLH GroundFLOOR like it or not", "", Colors.red),
    TimetableSlot.FromStrings(
        "8:00", "11:00", "Fri", "ES341", "ACB MLH", "", Colors.red),
    TimetableSlot.FromStrings(
        "10:00", "11:00", "Tue", "CS324", "ACB LH2", "", Colors.blue),
    TimetableSlot.FromStrings(
        "12:00", "13:00", "Wed", "CS311", "ACB LH5", "", Colors.orange),
    TimetableSlot.FromStrings(
        "8:00", "9:00", "Thu", "ES304", "ACB LH6", "", Colors.purple),
  ];

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  @override
  void initState() {
    super.initState();

    for (int i = 8; i <= 17; i++) {
      timeAxis.add('${i}:00');
      timeAxis.add('${i}:30');
    }
    print(timeAxis);

    // returnValue is equivalent to a-b (negative means b > a)
    TimetableSlots.sort((a, b) {
      if (a.dayNumber != b.dayNumber) {
        return a.dayNumber - b.dayNumber;
      }

      return a.startTime - b.startTime;
    });

    // not working apparently
    for (int i = 0; i < TimetableSlots.length - 1; i++) {
      if (TimetableSlots[i].dayNumber == TimetableSlots[i + 1].dayNumber) {
        // CHECK HOW IT LOOKS WHEN BOTH ARE EQUAL BELOW
        if (TimetableSlots[i].endTime > TimetableSlots[i + 1].startTime) {
          print(
              "CLASH: slots ${TimetableSlots[i].course} and ${TimetableSlots[i + 1].course}  on day ${TimetableSlots[i].dayString}.");
        }
      }
    }

    int currentDay = -1;
    int currentTime = 0;
    for (int i = 0; i < TimetableSlots.length; i++) {
      if (TimetableSlots[i].dayNumber > currentDay) {
        currentTime = 480 - TimeAxisUnitTime ~/ 2; // 8:00 AM;
        currentDay = TimetableSlots[i].dayNumber;
      }

      ContainersToPrint.add(TimetableSlot.FromValues(currentTime,
          TimetableSlots[i].startTime, TimetableSlots[i].dayNumber));
      ContainersToPrint.add(TimetableSlots[i]);
      currentTime = TimetableSlots[i].endTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Table"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      borderRadius: BorderRadius.circular(
                          30), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DropdownButton<String>(
                        selectedItemBuilder: (BuildContext context) {
                          return <String>[
                            'Choose your batch',
                            '33',
                            '32',
                            '31',
                            '30',
                            '29'
                          ].map((String value) {
                            // return Center(
                            //   child: Text(
                            //     value,
                            //     // textAlign: TextAlign.center,
                            //   )
                            // );
                            return SizedBox(
                                width: 152,
                                child: Center(
                                    child: Text(value,
                                        style:
                                            TextStyle(color: Colors.black))));
                          }).toList();
                        },
                        items: <String>[
                          'Choose your batch',
                          '33',
                          '32',
                          '31',
                          '30',
                          '29'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                                child: Text(
                              value,
                              // textAlign: TextAlign.center,
                            )),
                          );
                        }).toList(),
                        // value: selectedOption,
                        // onChanged: (newValue) {
                        //   setState(() {
                        //     selectedOption = newValue;
                        //   });

                        // },
                        onChanged: (String? value) => setState(() {
                          selectedBatch = value ?? "";
                        }),
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
                      borderRadius: BorderRadius.circular(
                          30), // Optional: Set border radius
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DropdownButton<String>(
                        selectedItemBuilder: (BuildContext context) {
                          return <String>[
                            'Choose your faculty',
                            'AI',
                            'CS',
                            'ME'
                          ].map((String value) {
                            return SizedBox(
                                width: 152,
                                child: Center(
                                    child: Text(value,
                                        style:
                                            TextStyle(color: Colors.black))));
                          }).toList();
                        },
                        items: <String>['Choose your faculty', 'AI', 'CS', 'ME']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                                child: Text(
                              value,
                              // textAlign: TextAlign.center,
                            )),
                          );
                        }).toList(),
                        onChanged: (String? value) => setState(() {
                          selectedFaculty = value ?? "";
                        }),
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
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align horizontally to the start (left)
                          children: [
                            // DAY AXIS
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: DayAxisBreadth,
                                  width: TimeAxisBreadth,
                                  color: getRandomColor(),
                                ),
                                for (int i = 0; i < daysAxis.length; i++)
                                  Container(
                                      height: DayAxisBreadth,
                                      width: DayAxisUnitLength,
                                      color: getRandomColor(),
                                      child: Center(child: Text(daysAxis[i]))),
                              ],
                            ),

                            // ALL BELOW DAY AXIS
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TIME AXIS
                                Column(
                                  children: [
                                    for (int i = 0; i < timeAxis.length; i++)
                                      Container(
                                          width: TimeAxisBreadth,
                                          height: TimeAxisUnitLength,
                                          color: getRandomColor(),
                                          child:
                                              Center(child: Text(timeAxis[i]))),
                                  ],
                                ),

                                // Class Slots (Row of columns of days)
                                Container(
                                  width:
                                      DayAxisUnitLength * (daysAxis.length * 1),
                                  height: TimeAxisUnitLength *
                                      (timeAxis.length * 1),
                                  color: getRandomColor(),
                                  child: Row(
                                    children: [
                                      for (int dayNumber = 0;
                                          dayNumber < 5;
                                          dayNumber++)
                                        Container(
                                          width: DayAxisUnitLength,
                                          height: TimeAxisUnitLength *
                                              (timeAxis.length * 1),
                                          color: DefaultGridColor,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (int containerNumber = 0;
                                                  containerNumber <
                                                      ContainersToPrint.length;
                                                  containerNumber++)
                                                if (ContainersToPrint[
                                                            containerNumber]
                                                        .dayNumber ==
                                                    dayNumber)
                                                  Container(
                                                    padding: EdgeInsets.all(5),
                                                    width: DayAxisUnitLength,
                                                    height: ContainersToPrint[
                                                            containerNumber]
                                                        .length,
                                                    color: ContainersToPrint[
                                                            containerNumber]
                                                        .color,
                                                    child: Align(
                                                      alignment: Alignment.center,        // vertical align
                                                      child: RichText(
                                                        textAlign: TextAlign.center,      // horizontal align
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily: 'Roboto',
                                                            color: Colors.black,
                                                            decoration: TextDecoration.none,
                                                          ),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text: ContainersToPrint[
                                                                        containerNumber]
                                                                    .course,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )
                                                              ),
                                                            TextSpan(
                                                              text: '\n',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                            ),
                                                            TextSpan(
                                                              text: ContainersToPrint[
                                                                      containerNumber]
                                                                  .venue,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 16),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Center(
                                                    //   child: Text(ContainersToPrint[
                                                    //               containerNumber]
                                                    //           .course +
                                                    //       "\n" +
                                                    //       ContainersToPrint[
                                                    //               containerNumber]
                                                    //           .venue),
                                                    // ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        )))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: editButtonPressed ? Colors.red : Colors.blue,
                    borderRadius:
                        BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor:
                          editButtonPressed ? Colors.red : Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (copyButtonPressed || resizeButtonPressed) {
                        } else {
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
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: resizeButtonPressed ? Colors.red : Colors.blue,
                    borderRadius:
                        BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor:
                          resizeButtonPressed ? Colors.red : Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (copyButtonPressed || editButtonPressed) {
                        } else {
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
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: copyButtonPressed ? Colors.red : Colors.blue,
                    borderRadius:
                        BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor:
                          copyButtonPressed ? Colors.red : Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        print(
                            "$editButtonPressed $resizeButtonPressed $copyButtonPressed");
                        if (editButtonPressed || resizeButtonPressed) {
                        } else {
                          copyButtonPressed = !copyButtonPressed;
                          if (copyButtonPressed == false) {
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
