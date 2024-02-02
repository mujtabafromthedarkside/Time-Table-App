import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:timetable/config/API_funcs.dart';
import 'package:timetable/config/config.dart';
import 'package:timetable/config/strings.dart';

import 'LandingPage.dart';

// Color GridColor = Color.fromARGB(255, 81, 157, 251);
// Color SlotColor = const Color.fromARGB(255, 244, 67, 54);
// Color DayAxisColor = Color.fromARGB(255, 0, 255, 255);
// Color TimeAxisColor = Color.fromARGB(255, 0, 255, 255);
// Color GridColor = Color.fromARGB(255, 255, 255, 255);
Color GridColor = Color(0xFFFFFFEC);
Color SlotColor = const Color.fromARGB(255, 244, 67, 54);
Color DayAxisColor = LandingPageDarkBlue;
Color TimeAxisColor = LandingPageDarkBlue;
Color DropdownsBFColor = LandingPageBrightYellow; // Batch, Faculty Color
Color EditButtonsColor = LandingPageBrightYellow;

Color DropdownsTextColor = Colors.white;
Color ButtonsTextColor = Colors.white;
Color AppBarTextColor = Colors.white;

double TimeAxisUnitLength = 65;
double DayAxisUnitLength = 72;

double TimeAxisBreadth = 60;
double DayAxisBreadth = 65;

double TimeAxisUnitTime = 30;
String TimeAxisStartTimeString = "08:00";
String TimeAxisEndTimeString = "17:30";

int convertTimeToInteger(String time) {
  int hours = int.parse(time.split(":")[0]);
  int minutes = int.parse(time.split(":")[1]);

  return hours * 60 + minutes;
}

int TimeAxisStartTime = convertTimeToInteger(TimeAxisStartTimeString);
int TimeAxisEndTime = convertTimeToInteger(TimeAxisEndTimeString);

String defaultBatchText = "Choose your batch";
String defaultFacultyText = "Choose your faculty";

Color getRandomColor() {
  Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    1.0,
  );
}

class TimetableSlot {
  late int startTime;
  late int endTime;
  late int dayNumber;

  String dayString = ""; // empty container has empty strings
  String endTimeString = "";
  String startTimeString = "";

  String course = "";
  String venue = "";
  String notes = "";

  Color? color = GridColor;
  // Color? color = getRandomColor();
  late double length;

  TimetableSlot.Empty() {
    this.color = SlotColor;
  }

  TimetableSlot.Copy(TimetableSlot other) {
    this.startTime = other.startTime;
    this.endTime = other.endTime;
    this.dayNumber = other.dayNumber;

    this.dayString = other.dayString;
    this.endTimeString = other.endTimeString;
    this.startTimeString = other.startTimeString;

    this.course = other.course;
    this.venue = other.venue;
    this.notes = other.notes;

    this.color = other.color;
    this.length = other.length;
  }

  TimetableSlot.FromStrings(this.startTimeString, this.endTimeString, this.dayString, this.course, this.venue, this.notes, this.color) {
    this.calculateValues();
  }

  TimetableSlot.FromValues(this.startTime, this.endTime, this.dayNumber) {
    // time ratio * unit length
    this.calculateLength();
  }

  void updateEndTime(int newEndTime) {
    this.endTime = newEndTime;
    this.calculateLength();
  }

  void calculateLength() {
    this.length = (this.endTime - this.startTime) / TimeAxisUnitTime * TimeAxisUnitLength;
  }

  void calculateValues() {
    int startHours = int.parse(startTimeString.split(":")[0]);
    int startMinutes = int.parse(startTimeString.split(":")[1]);

    int endHours = int.parse(endTimeString.split(":")[0]);
    int endMinutes = int.parse(endTimeString.split(":")[1]);

    this.startTime = startHours * 60 + startMinutes;
    this.endTime = endHours * 60 + endMinutes;

    // FOR FUTURE, raise error if dayString not in ["Mon", "Tue", "Wed", "Thu", "Fri"]
    this.dayNumber = ["Mon", "Tue", "Wed", "Thu", "Fri"].indexOf(dayString);
    if (this.dayNumber == -1) {
      this.dayNumber = ["monday", "tuesday", "wednesday", "thursday", "friday"].indexOf(dayString);
    }
    this.calculateLength();
  }
}

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  final List<TimetableSlot> ContainersToPrint = [];
  final List<TimetableSlot> TimetableSlots = [
    // TimetableSlot.FromStrings("10:00", "11:00", "Mon", "ES341", "ACB MLH", "", Colors.red),
    // TimetableSlot.FromStrings("8:00", "11:00", "Mon", "ES341", "ACB MLH GroundFLOOR like it or not", "", Colors.red),
    // TimetableSlot.FromStrings("8:00", "11:00", "Fri", "ES341", "ACB MLH", "", Colors.red),
    // TimetableSlot.FromStrings("10:00", "11:00", "Tue", "CS324", "ACB LH2", "", Colors.pink),
    // TimetableSlot.FromStrings("12:00", "13:00", "Wed", "CS311", "ACB LH5", "", Colors.orange),
    // TimetableSlot.FromStrings("8:00", "9:00", "Thu", "ES304", "ACB LH6", "", Colors.purple),
  ];

  bool addButtonPressed = false;
  int copyIndex = -1;
  final List<String> daysAxis = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  bool deleteButtonPressed = false;
  bool editButtonPressed = false;

  String selectedBatch = defaultBatchText;
  String selectedFaculty = defaultFacultyText;
  final List<String> texts = ['Text 1', 'Text 2'];
  final List<String> timeAxis = [];

  Map<String, String> toAddMap(TimetableSlot slot) {
    return {
      "faculty": selectedFaculty + selectedBatch,
      "day": slot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
      "start_time": slot.startTimeString,
      "end_time": slot.endTimeString,
      "venue": slot.venue,
      "subject": slot.course,
      "color": slot.color.toString().replaceFirst("Color(0xff", "#").replaceFirst(")", ""), // Also needs to be standardized.
    };
  }

  Map<String, String> toDeleteMap(TimetableSlot slot) {
    return {
      "faculty": selectedFaculty + selectedBatch,
      "day": slot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
      "start_time": slot.startTimeString,
    };
  }

  Map<String, String> toEditMap(TimetableSlot newSlot, TimetableSlot oldSlot) {
    return {
      "old_day": oldSlot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
      "old_start_time": oldSlot.startTimeString,

      "faculty": selectedFaculty + selectedBatch,
      "day": newSlot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
      "start_time": newSlot.startTimeString,
      "end_time": newSlot.endTimeString,
      "venue": newSlot.venue,
      "subject": newSlot.course,
      "color": newSlot.color.toString().replaceFirst("Color(0xff", "#").replaceFirst(")", ""), // Also needs to be standardized.
    };
  }

  bool insertTimetableSlot(TimetableSlot newSlot) {
    bool LiesInBetween(int x, int a, int b, int state) {
      if (state == 0) {
        if (x > a && x < b) return true;
      } else if (state == 1) {
        if (x >= a && x < b) return true;
      } else if (state == 2) {
        if (x > a && x <= b) return true;
      } else if (state == 3) {
        if (x >= a && x <= b) return true;
      }
      return false;
    }

    // if time does not lie in our axis
    if (!LiesInBetween(newSlot.startTime, TimeAxisStartTime, TimeAxisEndTime, 3)) return false;
    if (!LiesInBetween(newSlot.endTime, TimeAxisStartTime, TimeAxisEndTime, 3)) return false;

    int insertIndex = -1;
    bool indexFound = false;
    for (int i = 0; i < TimetableSlots.length; i++) {
      insertIndex = i;

      if (TimetableSlots[i].dayNumber == newSlot.dayNumber) {
        if (LiesInBetween(TimetableSlots[i].endTime, newSlot.startTime, newSlot.endTime, 2)) {
          print("CLASH: slots ${TimetableSlots[i].course} and ${newSlot.course}  on day ${TimetableSlots[i].dayString}.");
          return false;
        }

        if (LiesInBetween(TimetableSlots[i].startTime, newSlot.startTime, newSlot.endTime, 1)) {
          print("CLASH: slots ${TimetableSlots[i].course} and ${newSlot.course}  on day ${TimetableSlots[i].dayString}.");
          return false;
        }

        if (indexFound == false && TimetableSlots[i].startTime > newSlot.startTime) {
          indexFound = true;
          insertIndex = i;
          break;
        }
      } else if (indexFound == false && TimetableSlots[i].dayNumber > newSlot.dayNumber) {
        indexFound = true;
        insertIndex = i;
        break;
      }
    }

    if (!indexFound) {
      insertIndex++;
    }

    TimetableSlots.insert(insertIndex, newSlot);
    return true;
  }

  void updateContainersToPrint() {
    ContainersToPrint.clear();

    int currentDay = -1;
    int currentTime = 0;
    for (int i = 0; i < TimetableSlots.length; i++) {
      if (TimetableSlots[i].dayNumber > currentDay) {
        currentTime = 480 - TimeAxisUnitTime ~/ 2; // 8:00 AM;
        currentDay = TimetableSlots[i].dayNumber;
      }

      ContainersToPrint.add(TimetableSlot.FromValues(currentTime, TimetableSlots[i].startTime, TimetableSlots[i].dayNumber));
      ContainersToPrint.add(TimetableSlots[i]);
      currentTime = TimetableSlots[i].endTime;
    }
  }

  void deleteTimetableSlot(int containerNumber) {
    if (containerNumber < 0 || containerNumber >= ContainersToPrint.length) return;

    ContainersToPrint[containerNumber - 1].updateEndTime(ContainersToPrint[containerNumber].endTime);
    TimetableSlots.remove(ContainersToPrint[containerNumber]);
    ContainersToPrint.remove(ContainersToPrint[containerNumber]);

    if (containerNumber < ContainersToPrint.length && ContainersToPrint[containerNumber - 1].dayNumber == ContainersToPrint[containerNumber].dayNumber) {
      ContainersToPrint[containerNumber - 1].updateEndTime(ContainersToPrint[containerNumber].endTime);
      ContainersToPrint.remove(ContainersToPrint[containerNumber]);
    } else {
      ContainersToPrint.remove(ContainersToPrint[containerNumber - 1]);
    }
  }

  @override
  void initState() {
    super.initState();

    ResetDialogBoxValues();

    for (int i = 8; i <= 17; i++) {
      timeAxis.add('${i}:00');
      timeAxis.add('${i}:30');
    }

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
          print("CLASH: slots ${TimetableSlots[i].course} and ${TimetableSlots[i + 1].course}  on day ${TimetableSlots[i].dayString}.");
        }
      }
    }

    updateContainersToPrint();
  }

  late String selectedStartTimeInDialogBox;
  late String selectedEndTimeInDialogBox;
  late String selectedDay;
  late String enteredCourse;
  late String enteredVenue;
  late String enteredNotes;
  late Color selectedColor = SlotColor; // Initial color

  void ResetDialogBoxValues() {
    selectedStartTimeInDialogBox = "08:00 AM";
    selectedEndTimeInDialogBox = "09:00 AM";
    selectedDay = "Day";
    enteredCourse = "";
    enteredVenue = "";
    enteredNotes = "";
    selectedColor = SlotColor; // Initial color
  }

  String convertTimeToAMPM(String time) {
    int hours = int.parse(time.split(":")[0]);
    String minutes = time.split(":")[1];

    if (hours >= 12) {
      if (hours > 12) {
        hours -= 12;
      }
      return hours.toString() + ":" + minutes + " PM";
    } else {
      if (hours == 0) {
        hours = 12;
      }
      return hours.toString() + ":" + minutes + " AM";
    }
  }

  String convertTimeTo24Hours(String time) {
    String hours = time.split(":")[0];
    String minutes = time.split(":")[1].split(" ")[0];
    String ampm = time.split(":")[1].split(" ")[1];

    if (ampm == "AM") {
      if (hours == "12") {
        hours = "00";
      }
    } else {
      if (hours != "12") {
        hours = (int.parse(hours) + 12).toString();
      }
    }

    return hours + ":" + minutes;
  }

  int convertTimeToInteger(String time) {
    int hours = int.parse(time.split(":")[0]);
    int minutes = int.parse(time.split(":")[1]);

    return hours * 60 + minutes;
  }

  String convertTimeToString(int time) {
    String hours = (time ~/ 60).toString();
    String minutes = (time % 60).toString();

    return "$hours:${minutes.length == 1 ? "0$minutes" : minutes}";
  }

  Future<void> showViewDialog(BuildContext context, int containerNumber) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: ContainersToPrint[containerNumber].color,
              title: Text(
                ContainersToPrint[containerNumber].course + " - " + ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"][ContainersToPrint[containerNumber].dayNumber],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // fontSize: 20,
                ),
              ),
              content: Container(
                  // height: 300,
                  // width: 300,
                  // height: 350,
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                              child: Text(ContainersToPrint[containerNumber].startTimeString, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text("End Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                              child: Text(ContainersToPrint[containerNumber].endTimeString, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(ContainersToPrint[containerNumber].venue, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
                    if (ContainersToPrint[containerNumber].notes != "") Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    if (ContainersToPrint[containerNumber].notes != "") Text(ContainersToPrint[containerNumber].notes, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                  ]))));
        });
  }

  Future<void> showEditDialog(BuildContext context, int containerNumber) async {
    TextEditingController textControllerCourse = TextEditingController();
    textControllerCourse.text = enteredCourse;
    TextEditingController textControllerVenue = TextEditingController();
    textControllerVenue.text = enteredVenue;
    TextEditingController textControllerNotes = TextEditingController();
    textControllerNotes.text = enteredNotes;

    void UpdateValues() {
      enteredCourse = textControllerCourse.text;
      enteredVenue = textControllerVenue.text;
      enteredNotes = textControllerNotes.text;
    }

    void UpdateValuesAndReopen() {
      // setState(() {
      UpdateValues();
      // });

      // NOTE: I came to this after wasting too much time. For some reason, even though setState above works it doesn't modify the ElevatedButton text
      Navigator.of(context).pop();
      showEditDialog(context, containerNumber);
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Enter Details'),
          content: Container(
            // height: 300,
            // width: 300,
            // height: 350,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white, // Set the background color
                        borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              selectedItemBuilder: (BuildContext context) {
                                return <String>['Day', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((String value) {
                                  return Center(child: Text(value, style: TextStyle(color: Colors.black)));
                                }).toList();
                              },
                              items: <String>['Day', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((String value) {
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
                                selectedDay = value ?? "";
                            
                                UpdateValuesAndReopen();
                              }),
                              value: selectedDay,
                              icon: const Icon(Icons.arrow_downward), // Custom icon
                              iconSize: 20, // Set icon size
                              elevation: 0, // Dropdown menu elevation
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                              ),
                              dropdownColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("Start Time"),
                          ElevatedButton(
                            child: Text(selectedStartTimeInDialogBox),
                            onPressed: () async {
                              // Show the time picker dialog
                              final TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              // Do something with the selected time
                              if (selectedTime != null) {
                                print("setState called");
                                // setState(() {
                                selectedStartTimeInDialogBox = selectedTime.format(context);
                                // });
                              }

                              UpdateValuesAndReopen();
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text("End Time"),
                          ElevatedButton(
                            child: Text(selectedEndTimeInDialogBox),
                            onPressed: () async {
                              // Show the time picker dialog
                              final TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              // Do something with the selected time
                              if (selectedTime != null) {
                                print("setState called");
                                // setState(() {
                                selectedEndTimeInDialogBox = selectedTime.format(context);
                                // });
                              }

                              UpdateValuesAndReopen();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextField(
                    controller: textControllerCourse,
                    decoration: InputDecoration(labelText: 'Enter Course:', hintText: 'ES324'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textControllerVenue,
                    decoration: InputDecoration(labelText: 'Enter Venue:', hintText: 'ACB MLH'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    maxLines: 2,
                    controller: textControllerNotes,
                    decoration: InputDecoration(labelText: 'Enter Notes:', hintText: 'Quiz in this class'),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 130,
                    child: Center(
                      child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (Color color) {
                          selectedColor = color;
                        },
                        availableColors: [
                          Color.fromARGB(255, 255, 159, 152),
                          Color.fromARGB(255, 242, 86, 75),
                          const Color.fromARGB(255, 244, 67, 54),
                          Color.fromARGB(255, 197, 13, 0),
                          Color.fromARGB(255, 157, 245, 160),
                          Color.fromARGB(255, 80, 236, 85),
                          Color.fromARGB(255, 71, 189, 75),
                          Color.fromARGB(255, 28, 138, 31),
                          Color.fromARGB(255, 157, 207, 249),
                          Color.fromARGB(255, 82, 160, 225),
                          const Color.fromARGB(255, 33, 150, 243),
                          Color.fromARGB(255, 11, 108, 188),
                          Color.fromARGB(255, 255, 247, 176),
                          Color.fromARGB(255, 255, 241, 118),
                          Color.fromARGB(255, 255, 237, 72),
                          Color.fromARGB(255, 255, 230, 0),
                          Color.fromARGB(255, 255, 216, 156),
                          Color.fromARGB(255, 255, 192, 96),
                          Color.fromARGB(255, 255, 177, 60),
                          const Color.fromARGB(255, 255, 152, 0),
                          Color.fromARGB(255, 241, 160, 255),
                          Color.fromARGB(255, 206, 68, 231),
                          Color.fromARGB(255, 178, 42, 202),
                          Color.fromARGB(255, 159, 1, 187),
                          const Color.fromRGBO(255, 255, 255, 1),
                          const Color.fromRGBO(189, 189, 189, 1),
                          const Color.fromRGBO(97, 97, 97, 1),
                          const Color.fromRGBO(69, 90, 100, 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                // UI choice. Do we always want to restore previous values on cancel? Or only when we manually entered them?
                // if(!editingON)
                UpdateValues();

                // close the dialog
                Navigator.of(context).pop();
                // ResetDialogBoxValues();
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                // NOTE: Show WARNINGS HERE
                if (selectedDay == "Day") return;

                int selectedStartTime = convertTimeToInteger(convertTimeTo24Hours(selectedStartTimeInDialogBox));
                int selectedEndTime = convertTimeToInteger(convertTimeTo24Hours(selectedEndTimeInDialogBox));
                if (selectedStartTime >= selectedEndTime) return;

                // Make sure the time is between 8:00 AM and 5:30 PM
                // NOTE: Make constants her
                if (selectedStartTime < 480 || selectedEndTime > 1050) return;

                // Handle the input and close the dialog
                TimetableSlot newSlot = TimetableSlot.Empty();
                late TimetableSlot oldSlot;
                bool editingON = (containerNumber != -1);
                if (editingON) {
                  oldSlot = TimetableSlot.Copy(ContainersToPrint[containerNumber]);
                }

                newSlot.course = textControllerCourse.text.toUpperCase();
                newSlot.venue = textControllerVenue.text.toUpperCase();
                newSlot.notes = textControllerNotes.text;

                newSlot.dayString = selectedDay;
                newSlot.startTimeString = convertTimeToString(selectedStartTime);
                newSlot.endTimeString = convertTimeToString(selectedEndTime);

                newSlot.calculateValues();

                // NOTE: Take care of this above.
                // NOT SURE ABOUT THIS CONDITION
                if (selectedColor != SlotColor) {
                  newSlot.color = selectedColor;
                }

                if (editingON) {
                  deleteTimetableSlot(containerNumber);
                }

                if (insertTimetableSlot(newSlot) == false) {
                  print("CLASH: ${newSlot.course} on ${newSlot.dayString} has clash btw ${newSlot.startTime} and ${newSlot.endTime}.");

                  if (editingON)
                    insertTimetableSlot(oldSlot);
                  else
                    return;
                } // WILL NOT RETURN IF editingON because it needs to update Containers below.

                if (editingON) {
                  contactDatabase(context, 'update_timetable', toEditMap(newSlot, oldSlot)).then((returnStatus) {
                    if (returnStatus.isEmpty) return;

                    setState(() {
                      updateContainersToPrint();
                    });
                  });
                } else {
                  contactDatabase(context, 'add_timetable', toAddMap(newSlot)).then((returnStatus) {
                    if (returnStatus.isEmpty) return;

                    setState(() {
                      updateContainersToPrint();
                    });
                  });
                }

                print('Typed text course: ${textControllerCourse.text}');
                print('Typed text venue: ${textControllerVenue.text}');
                print('Typed text notes: ${textControllerNotes.text}');
                Navigator.of(context).pop();
                ResetDialogBoxValues();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingPageDarkBlue,
      appBar: AppBar(
        backgroundColor: LandingPageDarkBlue,
        title: Center(child: Text("Time Table App", style: TextStyle(color: AppBarTextColor))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppBarTextColor),
          onPressed: () {
            // Handle back button press here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LandingPage(),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Batch Dropdown
                  Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: LandingPageBrightYellow, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                      // Set decoration to null or an empty BoxDecoration to remove the border
                      // decoration: null,
                      border: Border.all(width: 2, color: Colors.transparent),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return <String>[defaultBatchText, '33', '32', '31', '30', '29'].map((String value) {
                                // return SizedBox(width: 152, child: Center(child: Text(value, style: TextStyle(color: Colors.black))));
                                return Center(child: Text(value, style: TextStyle(color: DropdownsTextColor, fontSize: 14)));
                              }).toList();
                            },
                            items: <String>[defaultBatchText, '33', '32', '31', '30', '29'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                    child: Text(
                                  value,
                                  style: TextStyle(color: DropdownsTextColor),
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
                            onChanged: (String? value) {
                              setState(() {
                                selectedBatch = value ?? "";
                              });

                              if (selectedFaculty != defaultFacultyText && selectedBatch != defaultBatchText) {
                                String faculty = selectedFaculty + selectedBatch;

                                Map<String, String> dataToSend = {"faculty": faculty};

                                contactDatabase(context, 'get_timetable', dataToSend).then((receivedTimetable) {
                                  setState(() {
                                    ReadTimetable(receivedTimetable);
                                  });
                                });
                              }
                            },
                            value: selectedBatch,
                            // onChanged: (_){},
                            // hint: const Text(defaultBatchText),

                            icon: Icon(Icons.arrow_downward, color: DropdownsTextColor), // Custom icon
                            iconSize: 20, // Set icon size
                            elevation: 0, // Dropdown menu elevation
                            style: TextStyle(
                              color: DropdownsTextColor,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                            dropdownColor: LandingPageBrightYellow,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Faculty Dropdown
                  Container(
                    width: 160,
                    decoration: BoxDecoration(
                      color: LandingPageBrightYellow, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return <String>[defaultFacultyText, 'AI', 'CS', 'ME'].map((String value) {
                                return Center(child: Text(value, style: TextStyle(color: DropdownsTextColor, fontSize: 14)));
                              }).toList();
                            },
                            items: <String>[defaultFacultyText, 'AI', 'CS', 'ME'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                    child: Text(value
                                        // textAlign: TextAlign.center,
                                        )),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedFaculty = value ?? "";
                              });
                          
                              if (selectedFaculty != defaultFacultyText && selectedBatch != defaultBatchText) {
                                String faculty = selectedFaculty + selectedBatch;
                          
                                Map<String, String> dataToSend = {"faculty": faculty};
                          
                                contactDatabase(context, 'get_timetable', dataToSend).then((receivedTimetable) {
                                  setState(() {
                                    ReadTimetable(receivedTimetable);
                                  });
                                });
                              }
                            },
                            value: selectedFaculty,
                            icon: Icon(Icons.arrow_downward, color: DropdownsTextColor), // Custom icon
                            iconSize: 20, // Set icon size
                            elevation: 0, // Dropdown menu elevation
                            style: TextStyle(
                              color: DropdownsTextColor,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                            dropdownColor: DropdownsBFColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Timetable
            Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align horizontally to the start (left)
                          children: [
                            // DAY AXIS
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: DayAxisBreadth,
                                  width: TimeAxisBreadth,
                                  color: DayAxisColor,
                                ),
                                for (int i = 0; i < daysAxis.length; i++)
                                  Container(
                                      height: DayAxisBreadth,
                                      width: DayAxisUnitLength,
                                      color: DayAxisColor,
                                      child: Center(
                                          child: Text(
                                        daysAxis[i],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ))),
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
                                          // color: TimeAxisColor,
                                          decoration: BoxDecoration(
                                            color: TimeAxisColor,
                                            // makes the border disappear, nice hack
                                            border: Border(bottom: BorderSide(color: TimeAxisColor, width: 0.0)),
                                          ),
                                          child: Center(
                                              child: Text(
                                            timeAxis[i],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))),
                                  ],
                                ),

                                // Class Slots (Row of columns of days)
                                Container(
                                  width: DayAxisUnitLength * (daysAxis.length * 1),
                                  height: TimeAxisUnitLength * (timeAxis.length * 1),
                                  color: getRandomColor(),
                                  child: Row(
                                    children: [
                                      for (int dayNumber = 0; dayNumber < 5; dayNumber++)
                                        Container(
                                          width: DayAxisUnitLength,
                                          height: TimeAxisUnitLength * (timeAxis.length * 1),
                                          color: GridColor,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (int containerNumber = 0; containerNumber < ContainersToPrint.length; containerNumber++)
                                                if (ContainersToPrint[containerNumber].dayNumber == dayNumber)
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (ContainersToPrint[containerNumber].dayString == "") return;

                                                      if (deleteButtonPressed) {
                                                        contactDatabase(context, 'delete_timetable', toDeleteMap(ContainersToPrint[containerNumber])).then((returnStatus) {
                                                          if (returnStatus.isEmpty) return;

                                                          setState(() {
                                                            deleteTimetableSlot(containerNumber);
                                                          });
                                                        });
                                                      } else if (editButtonPressed) {
                                                        selectedDay = ContainersToPrint[containerNumber].dayString;
                                                        selectedStartTimeInDialogBox = convertTimeToAMPM(ContainersToPrint[containerNumber].startTimeString);
                                                        selectedEndTimeInDialogBox = convertTimeToAMPM(ContainersToPrint[containerNumber].endTimeString);
                                                        enteredCourse = ContainersToPrint[containerNumber].course;
                                                        enteredVenue = ContainersToPrint[containerNumber].venue;
                                                        enteredNotes = ContainersToPrint[containerNumber].notes;
                                                        selectedColor = ContainersToPrint[containerNumber].color ?? SlotColor;
                                                        showEditDialog(context, containerNumber);
                                                      } else if (addButtonPressed) {
                                                      } else {
                                                        showViewDialog(context, containerNumber);
                                                      }
                                                    },
                                                    onDoubleTap: () {
                                                      // if (ContainersToPrint[containerNumber].dayString == "") return;
                                                      // if (deleteButtonPressed || addButtonPressed || editButtonPressed) return;

                                                      // showViewDialog(context, containerNumber);
                                                      // return;
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(5),
                                                      width: DayAxisUnitLength,
                                                      height: ContainersToPrint[containerNumber].length,
                                                      color: ContainersToPrint[containerNumber].color,
                                                      child: Align(
                                                        alignment: Alignment.center, // vertical align
                                                        child: RichText(
                                                          textAlign: TextAlign.center, // horizontal align
                                                          text: TextSpan(
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily: 'Roboto',
                                                              color: Colors.black,
                                                              decoration: TextDecoration.none,
                                                            ),
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                  text: ContainersToPrint[containerNumber].course,
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  )),
                                                              TextSpan(
                                                                text: '\n',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.normal,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: ContainersToPrint[containerNumber].venue,
                                                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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

            // Edit buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add Button
                Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: addButtonPressed ? Colors.red : EditButtonsColor,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: addButtonPressed ? Colors.red : EditButtonsColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        if (deleteButtonPressed || editButtonPressed) {
                        } else {
                          addButtonPressed = !addButtonPressed;
                          if (addButtonPressed) {
                            print("Add button unpressed");
                            addButtonPressed = false;
                          }
                        }
                      });
                      showEditDialog(context, -1);
                    },
                    child: Text(
                      addButtonPressed ? "Cancel" : "Add",
                      style: TextStyle(fontSize: 20, fontFamily: 'Roboto', color: ButtonsTextColor),
                    ),
                  ),
                ),

                // Edit Button
                Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: editButtonPressed ? Colors.red : EditButtonsColor,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: editButtonPressed ? Colors.red : EditButtonsColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (deleteButtonPressed || addButtonPressed) {
                        } else {
                          editButtonPressed = !editButtonPressed;
                        }
                      });
                    },
                    child: Text(
                      editButtonPressed ? "Cancel" : "Edit",
                      style: TextStyle(fontSize: 20, fontFamily: 'Roboto', color: ButtonsTextColor),
                    ),
                  ),
                ),

                // Delete Button
                Container(
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  decoration: BoxDecoration(
                    color: deleteButtonPressed ? Colors.red : EditButtonsColor,
                    borderRadius: BorderRadius.circular(30), // Adjust the radius
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      backgroundColor: deleteButtonPressed ? Colors.red : EditButtonsColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (addButtonPressed || editButtonPressed) {
                        } else {
                          deleteButtonPressed = !deleteButtonPressed;
                        }
                      });
                    },
                    child: Text(
                      deleteButtonPressed ? "Cancel" : "Delete",
                      style: TextStyle(fontSize: 20, fontFamily: 'Roboto', color: ButtonsTextColor),
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

  /// Construct a color from a hex code string, of the format #RRGGBB.
  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  ReadTimetable(Map<String, dynamic> Data) {
    TimetableSlots.clear();

    Data.forEach((day, slot) {
      if (slot == "")
        ;
      else {
        slot.forEach((startTime, remainingSlot) {
          insertTimetableSlot(TimetableSlot.FromStrings(
              startTime,
              remainingSlot["end_time"],
              day,
              remainingSlot["subject"],
              remainingSlot["venue"],
              // remainingSlot["notes"],
              "",
              hexToColor(remainingSlot["color"])));
        });
      }
    });

    updateContainersToPrint();
  }

  Future<Map<String, dynamic>> contactDatabase(BuildContext context, String suffixAPI, Map<String, String> dataToSend) async {
    try {
      String url = URL + suffixAPI;
      print(url);
      // final dataToSend = {
      //   "faculty": "AI31",
      //   "day": "friday",
      //   "color": "#FF5733",
      //   "start_time": "9:00",
      //   "end_time": "12:00",
      //   "venue": "LH3 FCSE",
      //   "subject": "CS221"
      // };
      final jsonData = await getterAPIWithDataPOST(url, data: dataToSend);
      print(jsonData);
      return jsonData;
    } catch (e) {
      // Handle any errors that occur during the API requests.
      print('Error: $e');
      return {};
    }
  }
}
