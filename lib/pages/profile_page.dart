import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:flutter_sample_test_3/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  toggleNightMode(DataProvider provider) {
    provider.toggleNightMode();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
      selector: (_, provider) => provider.colorConstants,
      builder: (_, colorConstants, __) => Scaffold(
        bottomNavigationBar: CustomBottomNavBar(),
        backgroundColor: colorConstants.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(
                  height: 12.0,
                ),
                TextWithSwitch(
                  text: "Night Mode",
                  detailText: "Turn app night mode on/off",
                  keyValue: colorConstants.nightMode,
                  keyCallback: (DataProvider provider) => toggleNightMode(provider),
                ),
                SizedBox(height: 32,),
                TextWithSwitch(
                  text: "Show Sticky Tasks",
                  detailText: "Tasks without an explicit date are considered sticky and added to the end of today's task list",
                  keyValue: Provider.of<DataProvider>(context).showDatelessTasks,
                  keyCallback: (DataProvider provider) {
                    provider.showDatelessTasks = !provider.showDatelessTasks;
                    provider.savePrefs();
                  },
                ),
                SizedBox(height: 32,),
                TextWithSwitch(
                  text: "Auto-delete Done Tasks",
                  detailText: "Automatically delete old tasks you have ticked as done",
                  keyValue: Provider.of<DataProvider>(context).autoDelete,
                  keyCallback: (DataProvider provider) {
                    provider.autoDelete = !provider.autoDelete;
                    provider.savePrefs();
                  },
                ),
                SizedBox(height: 32,),
                TextWithSwitch(
                  text: "Default Tasks to Sticky",
                  detailText: "Defaults the date field for adding tasks to sticky/dateless unless a date is explicitly set",
                  keyValue: Provider.of<DataProvider>(context).defaultToSticky,
                  keyCallback: (DataProvider provider) {
                    provider.defaultToSticky = !provider.defaultToSticky;
                    provider.savePrefs();
                  },
                ),
                SizedBox(height: 32,),
                TextWithSwitch(
                  text: "Show Category Suggestions",
                  detailText: "Show suggested category while you are typing",
                  keyValue: Provider.of<DataProvider>(context).suggestCategory,
                  keyCallback: (DataProvider provider) {
                    provider.suggestCategory = !provider.suggestCategory;
                    provider.savePrefs();
                  },
                ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}


class TextWithSwitch extends StatelessWidget {
  final String text;
  final bool keyValue;
  final Function keyCallback;
  final String detailText;


  TextWithSwitch({this.text = "", this.keyValue, this.keyCallback, this.detailText = ""});

  @override
  Widget build(BuildContext context) {
    return
      Consumer<DataProvider>(
        builder: (_, provider, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: provider.colorConstants.fontColor.withAlpha(230)),
                  ),
                  Text(
                    detailText,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: provider.colorConstants.fontColor.withAlpha(200)),

                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topRight,
                child: Switch(
                      value: keyValue,
                      activeColor: provider.colorConstants.widgetBackground,
                      activeTrackColor: provider.colorConstants.nightMode? ColorConstants.whiteFontColor: ColorConstants.greyBackground,
                      inactiveTrackColor: provider.colorConstants.nightMode? ColorConstants.greyBackground.withAlpha(50): ColorConstants.darkBackground.withAlpha(230),
                      inactiveThumbColor: provider.colorConstants.widgetBackground,
                      onChanged: (state) {
                        keyCallback(provider);
                      } ,
                    ),
              ),
            )
          ],
        ),
      );
  }
}
