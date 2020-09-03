import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    Key key,
    @required CalendarController calendarController,
  })  : _calendarController = calendarController,
        super(key: key);

  final CalendarController _calendarController;

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
      selector: (_, provider) => provider.colorConstants,
      builder: (_, colorConstants, __) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: colorConstants.secondaryBackgroundColor,
          boxShadow: [
            BoxShadow(
                offset: Offset(0.0, -4.0),
                blurRadius: 2.0,
                spreadRadius: -1.0,
                color: ColorConstants.darkBackground.withAlpha(100)),
          ],
        ),
        child: TableCalendar(
          onDaySelected: (DateTime date, _) => Provider.of<DataProvider>(context, listen: false).setSelectedDate(date),
          headerVisible: false,
          initialCalendarFormat: CalendarFormat.week,
          availableGestures: AvailableGestures.horizontalSwipe,
          calendarController: _calendarController,
          builders: CalendarBuilders(
              dowWeekdayBuilder: (BuildContext context, String weekday) => Center(
                  child: Text(
                    weekday,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: colorConstants.fontColor),
                  )),
              dayBuilder: (BuildContext context, DateTime day, _) => CalendarDay(
                day: day.day,
                weekday: day.weekday,
                isSelected: _calendarController.isSelected(day),
                isToday: _calendarController.isToday(day),
              )),
        ),
      ),
    );
  }
}

class CalendarDay extends StatelessWidget{
  final int day;
  final int weekday;
  final bool isSelected;
  final bool isToday;

  CalendarDay({this.day, this.weekday, this.isSelected, this.isToday});

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
    selector: (_, provider) => provider.colorConstants,
    builder: (_, colorConstants, __) => Padding(
        padding: isToday ? EdgeInsets.all(4.0) : (isSelected)? EdgeInsets.all(2.0): EdgeInsets.all(6.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(
            color: isSelected
                ? colorConstants.widgetBackground
                : colorConstants.widgetBackground.withAlpha(100),
            shape: isToday ? BoxShape.rectangle : BoxShape.circle,
            borderRadius:
            isToday ? BorderRadius.all(Radius.circular(12.0)) : null,
          ),
          child: Center(
            child: Text(
              "$day",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: ColorConstants.whiteFontColor),
            ),
          ),
        ),
      ),
    );
  }
}