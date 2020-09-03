import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/task.dart';

class Category {
  String name;
  Color color;

  int completedTaskNumber;
  int totalTaskNumber;


  //TODO Create an IconDATA generator
  IconData iconData = Icons.movie;

  Category({this.name, this.color, this.completedTaskNumber, this.totalTaskNumber}) {
    if (color == null) color = ColorConstants.categoryColors[0];
    name = name.toLowerCase();
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);

  Category.fake({this.name = "Default Name", this.color, this.completedTaskNumber = 10, this.totalTaskNumber = 12});

  ///Updates the completedTask and totalTask numbers using the given task
  updateStatsWithTask({Task task, UpdateType updateType, forceUpdate = false}){
    //Sanity check
    if (task.category != name && forceUpdate == false) return;


    switch (updateType) {
      case UpdateType.ADD : totalTaskNumber += 1;
      if (task.isDone) completedTaskNumber += 1;
      return;
      case UpdateType.REMOVE : totalTaskNumber -= 1;
      if (task.isDone) completedTaskNumber -= 1;
      return;
      case UpdateType.TOGGLE: if (task.isDone) completedTaskNumber += 1;
      else completedTaskNumber -= 1;
      return;
  }
    print("$completedTaskNumber : $totalTaskNumber");
  }
}


class CategoryColorGenerator {
  int _index;
  Random _random;
  UnmodifiableListView<Color> _colors;
  Map<String, Color> lookupTable;

  CategoryColorGenerator._() {
    _index = 0;
    _random = Random();
    _colors =
        UnmodifiableListView(ColorConstants.categoryColors..shuffle(_random));
    lookupTable = Map<String, Color>();
  }

  getColor(String categoryName) {
    if (!lookupTable.containsKey(categoryName)) {
      lookupTable[categoryName] = _colors[_index++];
      if (_index == _colors.length) _index = 0;
    }
    return lookupTable[categoryName];
  }

  static final CategoryColorGenerator _instance = CategoryColorGenerator._();

  factory CategoryColorGenerator() {
    return _instance;
  }
}

enum UpdateType{
  ADD, REMOVE, TOGGLE
}