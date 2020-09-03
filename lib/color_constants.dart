import 'package:flutter/material.dart';

class ColorConstants{
  static Color lightBackground = const Color(0xfff3f3f3);
  static Color darkBackground = const Color(0xff3b3b3b);
  static Color blackFontColor = const Color(0xff2e2e2e);
  static Color whiteFontColor = const Color(0xfffbfbfb);
  static Color greyBackground = const Color(0xffbab7cc);
  static Color purple = const Color(0xff443f79);
  static Color pink = const Color(0xeff07c7c);
  static Color orange = const Color(0xfff2a265);
  static Color opal = const Color(0xff9ac2c5);
  static Color green = const Color(0xffafe3c0);
  static Color blue = const Color(0xff63b0cd);
  static Color seaweed = const Color(0xff028090);
  static Color brown = const Color(0xfff5dfbb);
  static Color jungleGrey = const Color(0xff8EA604);
  static Color red = const Color(0xff721817);

  static List<Color> categoryColors = [purple, pink, orange, opal, green, blue, seaweed, brown, jungleGrey];

  bool nightMode;
  Color background;
  Color invertedBackground;
  Color secondaryBackgroundColor;
  Color widgetBackground;
  Color secondaryWidgetBackground;
  Color fontColor;

  ColorConstants(this.nightMode){
    assignColors();
  }

  toggleNightMode(){
    nightMode = !nightMode;
    assignColors();
  }

  assignColors(){
    background = nightMode? darkBackground:lightBackground;
    invertedBackground = nightMode? lightBackground:darkBackground;
    secondaryBackgroundColor = nightMode? blackFontColor:whiteFontColor;
    widgetBackground = nightMode? pink: purple;
    secondaryWidgetBackground = nightMode? orange: seaweed;
    fontColor = nightMode? whiteFontColor: blackFontColor;

  }


}