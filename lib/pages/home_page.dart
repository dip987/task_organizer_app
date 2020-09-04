import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:flutter_sample_test_3/widgets/calendar_widgets.dart';
import 'package:flutter_sample_test_3/widgets/category_card_widgets.dart';
import 'package:flutter_sample_test_3/widgets/navigation_bar.dart';
import 'package:flutter_sample_test_3/widgets/task_widgets.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _calendarController;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }


  String greetingText() {
    var hour = DateTime.now().hour;
    if (hour >=0 && hour <=5) return 'Late Nights?';
    if (hour < 12 && hour>5) return 'Good Morning,';
    if (hour < 18) return 'Good Afternoon,';
    else return 'Good Evening,';

  }

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
      selector: (_, provider) => provider.colorConstants,
      builder: (_, colorConstants, __) =>Scaffold(
          bottomNavigationBar: CustomBottomNavBar(),
          backgroundColor: colorConstants.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    Container(
                      color: colorConstants.secondaryBackgroundColor,
                      child: TyperAnimatedTextKit(
                          text: [greetingText()],
                          speed: Duration(milliseconds: 300),
                          isRepeatingAnimation: false,
                          textStyle: Theme.of(context).textTheme.headline4.copyWith(color: colorConstants.fontColor.withAlpha(150))),

                    ),
                    Container(color: colorConstants.secondaryBackgroundColor, child: Text(Provider.of<DataProvider>(context).userName, style: Theme.of(context).textTheme.headline5.copyWith(color: colorConstants.fontColor))),
                  ]),
                ),
                SliverAppBar(
                  titleSpacing: 0.0,
                  automaticallyImplyLeading: false,
                  floating: true,
                  pinned: true,
                  toolbarHeight: 300.0,
                  backgroundColor: colorConstants.secondaryBackgroundColor,
                  title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                      [
                        CalendarStrip(calendarController: _calendarController,),
                        SizedBox(height: 4.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: CategoryCard.horizontalMargin, vertical: 0.0),
                        child: Text("Categories", style: Theme.of(context).textTheme.headline5.copyWith(color: colorConstants.fontColor.withAlpha(220))),
                      ),
                    ),
                        SizedBox(height: 4.0),
                        CategoryCardList(),
                      ]
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: CategoryCard.horizontalMargin, vertical: 0.0),
                        child: Selector<DataProvider, String>(
                            selector: (_, dataProvider) => dataProvider.dayString,
                            builder: (_, data, __) => TyperAnimatedTextKit(key: ValueKey<String>(data), isRepeatingAnimation: false, text: [data], textStyle: Theme.of(context).textTheme.headline5.copyWith(color: colorConstants.fontColor.withAlpha(220)))),
                      ),
                    ]
                  ),
                ),
                TaskStripSliver(),
              ],
            ),
          )),
    );
  }
}



