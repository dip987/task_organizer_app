import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';


export 'package:flutter_sample_test_3/widgets/task_widgets.dart';


class Task {
  DateTime date;
  String name;
  bool isDone;
  String category;
  Color color;
  int databaseKey;


  Task({this.name = "Default Task",
    this.isDone = false,
    this.category = "Others",
    this.color = Colors.grey,
    this.date}){category = category.toLowerCase();}

  void toggle() {
    isDone = !isDone;
  }

  @override
  String toString() {
    return "name : $name, done? : $isDone, category : $category, date: $date";
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "isDone": isDone,
      "category": category,
      "hasDate" : date != null,
      "year": date?.year,
      "month": date?.month,
      "day": date?.day,
    };
  }

  Task.fromJson(Map<String, dynamic> jsonMap) {
    if (jsonMap["hasDate"]){
      date = DateTime(jsonMap["year"], jsonMap["month"], jsonMap["day"]);
    }
    else date = null;
    name = jsonMap["name"];
    isDone = jsonMap["isDone"];
    category = jsonMap["category"];
  }
}

class TaskGenerator {
  static Map<String, Color> _map = {
    "Cyan": ColorConstants.green,
    "Blue": ColorConstants.blue,
    "Red": ColorConstants.pink,
    "Orange": ColorConstants.orange,
    "Purple": ColorConstants.purple,
    "Opal": ColorConstants.opal,
    "Seaweed": ColorConstants.seaweed,
  };
  static Random random = Random();

  static generate(int index) {
    int randIndex = random.nextInt(_map.length);
    return Task(
        name: "Task Number $index",
        isDone: random.nextBool(),
        category: _map.keys.toList()[randIndex],
        color: _map.values.toList()[randIndex]);
  }
}


