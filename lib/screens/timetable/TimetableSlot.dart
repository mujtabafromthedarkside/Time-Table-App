import 'package:flutter/material.dart';
import 'package:timetable/config/strings.dart';

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

