import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:timetable/config/API_funcs.dart';
import 'package:timetable/config/constants.dart';

import 'package:timetable/screens/login.dart';
import 'package:timetable/screens/LandingPage.dart';

import 'package:timetable/screens/SideBar.dart';
import 'package:timetable/screens/timetable/TimetableSlot.dart';

import 'package:timetable/screens/timetable/utils.dart';

int TimeAxisStartTime = convertTimeToInteger(TimeAxisStartTimeString);
int TimeAxisEndTime = convertTimeToInteger(TimeAxisEndTimeString);

class specificTimeString {
  late String time;

  specificTimeString(this.time);

  TimeOfDay toTimeOfDay() {
    String time = convertTimeTo24Hours(this.time);
    return TimeOfDay(hour: int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1].split(" ")[0]));
  }
}

class TimeTablePage extends StatefulWidget {
  const TimeTablePage({super.key});

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  // DROPDOWN VALUES
  String selectedBatch = defaultBatchText;
  String selectedFaculty = defaultFacultyText;
  final List<String> texts = ['Text 1', 'Text 2'];
  final List<String> timeAxis = [];

  // USEFUL ARRAYS
  final List<String> daysAxis = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  final List<TimetableSlot> ContainersToPrint = [];
  final List<TimetableSlot> TimetableSlots = [
    // TimetableSlot.FromStrings("10:00", "11:00", "Mon", "ES341", "ACB MLH", "", Colors.red),
    // TimetableSlot.FromStrings("8:00", "11:00", "Mon", "ES341", "ACB MLH GroundFLOOR like it or not", "", Colors.red),
    // TimetableSlot.FromStrings("8:00", "11:00", "Fri", "ES341", "ACB MLH", "", Colors.red),
    // TimetableSlot.FromStrings("10:00", "11:00", "Tue", "CS324", "ACB LH2", "", Colors.pink),
    // TimetableSlot.FromStrings("12:00", "13:00", "Wed", "CS311", "ACB LH5", "", Colors.orange),
    // TimetableSlot.FromStrings("8:00", "9:00", "Thu", "ES304", "ACB LH6", "", Colors.purple),
  ];

  // BOOLEANS FOR BUTTONS
  bool addButtonPressed = false;
  bool deleteButtonPressed = false;
  bool editButtonPressed = false;
  bool isLoading = false;

  // ADD/EDIT DIALOG BOX VALUES
  late specificTimeString selectedStartTimeInDialogBox = specificTimeString("08:00 AM");
  late specificTimeString selectedEndTimeInDialogBox = specificTimeString("09:00 AM");
  late String selectedDay;
  late String enteredCourse;
  late String enteredVenue;
  late String enteredNotes;
  late Color selectedColor = SlotColor; // Initial color

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

  void ResetDialogBoxValues() {
    selectedStartTimeInDialogBox.time = "08:00 AM";
    selectedEndTimeInDialogBox.time = "09:00 AM";
    selectedDay = "Day";
    enteredCourse = "";
    enteredVenue = "";
    enteredNotes = "";
    selectedColor = SlotColor; // Initial color
    editDialogWarningPrompt = "";
  }

  Future<void> showViewDialog(BuildContext context, int containerNumber) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: ContainersToPrint[containerNumber].color,
              title: Text(
                ContainersToPrint[containerNumber].course + " - " + ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"][ContainersToPrint[containerNumber].dayNumber],
                style: TextStyle(fontWeight: FontWeight.bold, color: GridTextColor
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
                            Text("Start Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: GridTextColor)),
                            Container(
                              child: Text(ContainersToPrint[containerNumber].startTimeString, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: GridTextColor)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text("End Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: GridTextColor)),
                            Container(
                              child: Text(ContainersToPrint[containerNumber].endTimeString, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: GridTextColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: GridTextColor)),
                    Text(ContainersToPrint[containerNumber].venue, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: GridTextColor)),
                    if (ContainersToPrint[containerNumber].notes != "") Text("Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: GridTextColor)),
                    if (ContainersToPrint[containerNumber].notes != "")
                      Text(ContainersToPrint[containerNumber].notes, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: GridTextColor)),
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

    Future<TimeOfDay?> showCustomTimePicker(BuildContext context, TimeOfDay initialTime) {
      return showTimePicker(
        context: context,
        // initialTime: TimeOfDay.now(),
        initialTime: initialTime,
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                error: LandingPageDarkBlue,
                // background: LandingPageDarkBlue,
                //     onBackground: EditDialogTextColor,
                surface: LandingPageDarkBlue,
                //     onSurface: EditDialogTextColor,
                primary: LandingPageBrightYellow,
                //     onPrimary: Colors.black,
                secondary: LandingPageBrightYellow,
                //     onSecondary: Colors.black,
                // tertiary: LandingPageBrightYellow,
              ),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary, buttonColor: LandingPageBrightYellow),
            ),
            child: child!,
          );
        },
      );
    }

    Column customTimeButton(BuildContext context, String heading, specificTimeString selectedTimeInDialogBox) {
      return Column(
        children: [
          Text(heading, style: TextStyle(fontWeight: FontWeight.normal)),
          Container(
            width: customTimeButtonWIDTH,
            height: customTimeButtonHEIGHT,
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: ElevatedButton(
              child: Text(convertTimeTo24Hours(selectedTimeInDialogBox.time), style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Adjust the value to control the roundness
                    // You can also specify other border properties here such as side: BorderSide(color: Colors.red)
                  ),
                  backgroundColor: EditDialogButtonsColor,
                  foregroundColor: EditDialogTextColor,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0)),
              onPressed: () async {
                // Show the time picker dialog
                final TimeOfDay? selectedTime = await showCustomTimePicker(context, selectedTimeInDialogBox.toTimeOfDay());

                // Do something with the selected time
                if (selectedTime != null) {
                  print("setState called");
                  // setState(() {
                  selectedTimeInDialogBox.time = selectedTime.format(context);
                  // });
                }

                UpdateValuesAndReopen();
              },
            ),
          ),
        ],
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: LandingPageDarkBlue,
          title: Text('Enter Details', style: TextStyle(color: EditDialogTextColor)),
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
                      customTimeButton(context, "Start", selectedStartTimeInDialogBox),
                      customTimeButton(context, "End", selectedEndTimeInDialogBox),
                      Column(
                        children: [
                          Text("Day", style: TextStyle(fontWeight: FontWeight.normal)),
                          Container(
                            width: customTimeButtonWIDTH,
                            height: customTimeButtonHEIGHT,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            decoration: BoxDecoration(
                              color: DropdownsBFColor, // Set the background color
                              // borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                              borderRadius: BorderRadius.circular(20.0), // Optional: Set border radius
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(19, 0, 4, 0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    selectedItemBuilder: (BuildContext context) {
                                      return <String>['Day', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((String value) {
                                        return Center(child: Text(value, style: TextStyle(color: EditDialogTextColor)));
                                      }).toList();
                                    },
                                    items: <String>['Day', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Center(
                                            child: Text(
                                          value,
                                          style: TextStyle(color: EditDialogTextColor, fontWeight: (value == "Day" ? FontWeight.bold : FontWeight.normal)),
                                          // textAlign: TextAlign.center,
                                        )),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) => setState(() {
                                      selectedDay = value ?? "";

                                      UpdateValuesAndReopen();
                                    }),
                                    value: selectedDay,
                                    icon: Icon(Icons.arrow_downward, color: EditDialogTextColor), // Custom icon
                                    iconSize: 15, // Set icon size
                                    elevation: 0, // Dropdown menu elevation
                                    style: TextStyle(
                                      color: EditDialogTextColor,
                                      fontSize: 14,
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
                    ],
                  ),
                  TextField(
                    controller: textControllerCourse,
                    decoration: InputDecoration(
                        labelText: 'Enter Course:', labelStyle: TextStyle(color: Colors.grey), hintText: 'ES324', hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal)),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textControllerVenue,
                    decoration: InputDecoration(
                        labelText: 'Enter Venue:', labelStyle: TextStyle(color: Colors.grey), hintText: 'ACB MLH', hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal)),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    maxLines: 2,
                    controller: textControllerNotes,
                    decoration: InputDecoration(
                        labelText: 'Enter Notes:',
                        labelStyle: TextStyle(color: Colors.grey),
                        hintText: 'Quiz in this class',
                        hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal)),
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
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Center(
                        child: Text(
                      editDialogWarningPrompt,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SlotColor, fontSize: 16, fontWeight: FontWeight.normal),
                    )),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 5),
              width: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EditDialogButtonsColor,
                  padding: EdgeInsets.all(0),
                ),
                child: Text('Cancel', style: TextStyle(color: EditDialogTextColor, fontWeight: FontWeight.normal)),
                onPressed: () {
                  // UI choice. Do we always want to restore previous values on cancel? Or only when we manually entered them?
                  // if(!editingON)
                  UpdateValues();
                  editDialogWarningPrompt = "";

                  // close the dialog
                  Navigator.of(context).pop();
                  // ResetDialogBoxValues();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              width: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EditDialogButtonsColor,
                  padding: EdgeInsets.all(0),
                ),
                child: Text('OK', style: TextStyle(color: EditDialogTextColor, fontWeight: FontWeight.normal)),
                onPressed: () {
                  // NOTE: Show WARNINGS HERE
                  if (selectedDay == "Day") {
                    print("Day not selected!!");
                    editDialogWarningPrompt = "Please select a day to proceed!";
                    UpdateValuesAndReopen();
                    return;
                  }

                  int selectedStartTime = convertTimeToInteger(convertTimeTo24Hours(selectedStartTimeInDialogBox.time));
                  int selectedEndTime = convertTimeToInteger(convertTimeTo24Hours(selectedEndTimeInDialogBox.time));
                  if (selectedStartTime >= selectedEndTime) {
                    print("Start time must be before end time!");
                    editDialogWarningPrompt = "Start time must be before end time!";
                    UpdateValuesAndReopen();
                    return;
                  }

                  // Make sure the time is between 8:00 AM and 5:30 PM
                  // NOTE: Make constants her
                  if (selectedStartTime < 480 || selectedEndTime > 1050) {
                    print("Time must be between 8:00 AM and 5:30 PM!");
                    editDialogWarningPrompt = "Time must be between 8:00 AM and 5:30 PM!";
                    UpdateValuesAndReopen();
                    return;
                  }

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

                  // NOTE: Check on fe only
                  if (insertTimetableSlot(newSlot) == false) {
                    print("CLASH: ${newSlot.course} on ${newSlot.dayString} has clash btw ${newSlot.startTime} and ${newSlot.endTime}.");

                    if (editingON) {
                      insertTimetableSlot(oldSlot);
                      setState(() {
                        updateContainersToPrint();
                      });
                    }

                    editDialogWarningPrompt = "Clash with another slot detected!";
                    UpdateValuesAndReopen();
                    return;
                  } // WILL NOT RETURN IF editingON because it needs to update Containers below.

                  if (editingON) {
                    Map<String, String> dataToSend = toEditMap(newSlot, oldSlot);
                    dataToSend['faculty'] = selectedFaculty + selectedBatch;

                    contactDatabase(context, 'update_timetable', dataToSend).then((returnStatus) {
                      if (returnStatus.isEmpty) return;

                      setState(() {
                        updateContainersToPrint();
                      });
                    });
                  } else {
                    Map<String, String> dataToSend = toAddMap(newSlot);
                    dataToSend['faculty'] = selectedFaculty + selectedBatch;

                    contactDatabase(context, 'add_timetable', dataToSend).then((returnStatus) {
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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    DayAxisUnitLength = (screenWidth - TimeAxisBreadth) / 5;

    return Scaffold(
      backgroundColor: LandingPageDarkBlue,
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: LandingPageDarkBlue,
        title: Text("Time Table App", style: TextStyle(color: AppBarTextColor)),
        centerTitle: true,
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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                if (loggedIn) {
                  setState(() {
                    loggedIn = false;
                  });

                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
              child: Text(
                loggedIn ? "Logout" : "Login",
                style: TextStyle(fontSize: 15, fontFamily: 'Roboto', color: Colors.grey),
              ),
            ),
          ),
        ],
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
                    height: DropdownsBFHeight,
                    width: DropdownsBFWidth,
                    decoration: BoxDecoration(
                      color: LandingPageBrightYellow, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                      // Set decoration to null or an empty BoxDecoration to remove the border
                      // decoration: null,
                      border: Border.all(width: 0, color: Colors.transparent),
                    ),
                    child: Center(
                      child: Padding(
                        // padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: EdgeInsets.fromLTRB(19, 0, 4, 0),
                        child: Theme(
                          data: Theme.of(context).copyWith(canvasColor: Colors.green[300]),
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
                                    style: TextStyle(color: DropdownsTextColor, fontWeight: (value == defaultBatchText ? FontWeight.bold : FontWeight.normal)),
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
                              iconSize: 15, // Set icon size
                              elevation: 0, // Dropdown menu elevation
                              style: TextStyle(
                                color: DropdownsTextColor,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.normal,
                              ),
                              dropdownColor: Color.fromARGB(250, 233, 161, 26),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Faculty Dropdown
                  Container(
                    height: DropdownsBFHeight,
                    width: DropdownsBFWidth,
                    decoration: BoxDecoration(
                      color: LandingPageBrightYellow, // Set the background color
                      borderRadius: BorderRadius.circular(30), // Optional: Set border radius
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(19, 0, 4, 0),
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
                                    child: Text(
                                  value,
                                  style: TextStyle(color: DropdownsTextColor, fontWeight: (value == defaultFacultyText ? FontWeight.bold : FontWeight.normal)),
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
                            iconSize: 15, // Set icon size
                            elevation: 0, // Dropdown menu elevation
                            style: TextStyle(
                              color: DropdownsTextColor,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                            ),
                            dropdownColor: Color.fromARGB(250, 233, 161, 26),
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
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          // Set the color of the spinner
                          valueColor: AlwaysStoppedAnimation<Color>(DropdownsTextColor),

                          // Set the strokeWidth (thickness of the spinner)
                          strokeWidth: 4.0,

                          // Set the background color of the spinner
                          backgroundColor: DropdownsBFColor,
                        ),
                      )
                    : SingleChildScrollView(
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
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
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
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
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
                                                            Map<String, String> dataToSend = toDeleteMap(ContainersToPrint[containerNumber]);
                                                            dataToSend['faculty'] = selectedFaculty + selectedBatch;

                                                            contactDatabase(context, 'delete_timetable', dataToSend).then((returnStatus) {
                                                              if (returnStatus.isEmpty) return;

                                                              setState(() {
                                                                deleteTimetableSlot(containerNumber);
                                                              });
                                                            });
                                                          } else if (editButtonPressed) {
                                                            selectedDay = ContainersToPrint[containerNumber].dayString;
                                                            selectedStartTimeInDialogBox.time = convertTimeToAMPM(ContainersToPrint[containerNumber].startTimeString);
                                                            selectedEndTimeInDialogBox.time = convertTimeToAMPM(ContainersToPrint[containerNumber].endTimeString);
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

            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Center(
                  child: Text(
                ButtonPrompt,
                style: TextStyle(color: SlotColor, fontSize: 16, fontWeight: FontWeight.normal),
              )),
            ),

            // Edit buttons row
            loggedIn == false
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Add Button
                      Container(
                        // color: Colors.red,
                        width: ButtonsWidth,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        // decoration: BoxDecoration(
                        // color: addButtonPressed ? Colors.red : EditButtonsColor,
                        // borderRadius: BorderRadius.circular(30), // Adjust the radius
                        // border: Border.all(width: 0, color: Colors.transparent),
                        // ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: addButtonPressed ? CancelColor : EditButtonsColor,
                            // foregroundColor: Colors.black,
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(30),
                            // ),
                          ),
                          onPressed: () async {
                            if (deleteButtonPressed || editButtonPressed) return;
                            setState(() {
                              addButtonPressed = !addButtonPressed;
                            });
                            showEditDialog(context, -1);
                            addButtonPressed = false;
                          },
                          child: Text(
                            addButtonPressed ? "Cancel" : "Add",
                            style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.normal, color: ButtonsTextColor),
                          ),
                        ),
                      ),

                      // Edit Button
                      Container(
                        // color: Colors.red,
                        width: ButtonsWidth,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        // decoration: BoxDecoration(
                        // color: editButtonPressed ? Colors.red : EditButtonsColor,
                        // borderRadius: BorderRadius.circular(30), // Adjust the radius
                        // border: Border.all(width: 0, color: Colors.transparent),
                        // ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: editButtonPressed ? CancelColor : EditButtonsColor,
                            // foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (deleteButtonPressed || addButtonPressed) {
                              } else {
                                editButtonPressed = !editButtonPressed;
                                if (editButtonPressed) {
                                  ButtonPrompt = editButtonPrompt;
                                } else {
                                  ButtonPrompt = defaultButtonPrompt;
                                }
                              }
                            });
                          },
                          child: Text(
                            editButtonPressed ? "Cancel" : "Edit",
                            style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.normal, color: ButtonsTextColor),
                          ),
                        ),
                      ),

                      // Delete Button
                      Container(
                        // color: Colors.red,
                        width: ButtonsWidth,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        // decoration: BoxDecoration(
                        //   color: deleteButtonPressed ? Colors.red : EditButtonsColor,
                        //   borderRadius: BorderRadius.circular(30), // Adjust the radius
                        // ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            backgroundColor: deleteButtonPressed ? CancelColor : EditButtonsColor,
                            // foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              if (addButtonPressed || editButtonPressed) {
                              } else {
                                deleteButtonPressed = !deleteButtonPressed;
                                if (deleteButtonPressed) {
                                  ButtonPrompt = deleteButtonPrompt;
                                } else {
                                  ButtonPrompt = defaultButtonPrompt;
                                }
                              }
                            });
                          },
                          child: Text(
                            deleteButtonPressed ? "Cancel" : "Delete",
                            style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.normal, color: ButtonsTextColor),
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
      setState(() {
        isLoading = true;
      });

      final jsonData = await getterAPIWithDataPOST(url, data: dataToSend);

      setState(() {
        isLoading = false;
      });

      print(jsonData);
      return jsonData;
    } catch (e) {
      // Handle any errors that occur during the API requests.
      print('Error: $e');
      return {};
    }
  }
}
