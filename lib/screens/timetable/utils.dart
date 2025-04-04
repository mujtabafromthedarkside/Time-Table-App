import 'package:flutter/material.dart'; // Color
import 'dart:math'; // Random
import 'package:timetable/screens/timetable/TimetableSlot.dart';
import 'package:timetable/config/constants.dart';

// COLORS
Color getRandomColor() {
  Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    1.0,
  );
}

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

// PREPARING JSONS FOR APIs
Map<String, String> toAddMap(TimetableSlot slot) {
  return {
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
    "day": slot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
    "start_time": slot.startTimeString,
  };
}

Map<String, String> toEditMap(TimetableSlot newSlot, TimetableSlot oldSlot) {
  return {
    "old_day": oldSlot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
    "old_start_time": oldSlot.startTimeString,

    "day": newSlot.dayString, // This will cause problems since backend uses full day name while I use first 3 letters, but insertTimetableSlot() should handle it
    "start_time": newSlot.startTimeString,
    "end_time": newSlot.endTimeString,
    "venue": newSlot.venue,
    "subject": newSlot.course,
    "color": newSlot.color.toString().replaceFirst("Color(0xff", "#").replaceFirst(")", ""), // Also needs to be standardized.
  };
}

// TIME CONVERSIONS
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
