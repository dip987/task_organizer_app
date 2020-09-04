import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatefulWidget {
  static final double borderRadius = 40.0;

  final Function callback;

  CustomBottomNavBar({this.callback});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String _currentRoute;
  int _index;
  static final Map<String, int> indexMap = {'/home' : 0, '/add' : 1, '/profile' : 2};


  @override
  Widget build(BuildContext context) {
    _currentRoute = ModalRoute.of(context).settings.name;
    _index = indexMap[_currentRoute];
    return Selector<DataProvider, ColorConstants>(
      selector: (_, provider) => provider.colorConstants,
      builder: (_, colorConstants, __) => Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(CustomBottomNavBar.borderRadius), topRight: Radius.circular(CustomBottomNavBar.borderRadius)),
            color: colorConstants.secondaryBackgroundColor,
            boxShadow: [BoxShadow(color: ColorConstants.greyBackground.withAlpha(100))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(child: Icon(Icons.home, color: _index == 0? colorConstants.widgetBackground : ColorConstants.greyBackground,), onPressed: (){
              //If the icon pressed has the same index as the current route, call the route callback
              if (widget.callback != null && _index == 0) widget.callback();

              if (_index != 0){
                Navigator.popUntil(context, ModalRoute.withName('/home'));
              }
            },
              shape: CircleBorder(),
              padding: EdgeInsets.all(20.0),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: FlatButton(
                onPressed: (){
                  if (widget.callback != null && _index == 1) widget.callback();

                  //Prevents Creation of Unnecessary Routes
                  //Makes it so that the Stack only ever has 2 Pages at max. Home and this
                  if (_index != 1){
                    if(_index == 0) {Navigator.pushNamed(context, '/add');}
                    else Navigator.of(context).popAndPushNamed('/add');
                  }
                },
                shape: CircleBorder(),
                  color: (_index == 1)? colorConstants.secondaryWidgetBackground : colorConstants.widgetBackground,
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.add, color: ColorConstants.lightBackground,)),
            ),
            FlatButton(child: Icon(Icons.person, color: _index == 2? colorConstants.widgetBackground : ColorConstants.greyBackground,), onPressed: (){
              if (widget.callback != null && _index == 2) widget.callback();

              //Prevents Creation of Unnecessary Routes
              //Makes it so that the Stack only ever has 2 Pages at max. Home and this
              if (_index != 2){
                if(_index == 0) {Navigator.pushNamed(context, '/profile');}
                else Navigator.of(context).popAndPushNamed('/profile');
              }
            },
              shape: CircleBorder(),
              padding: EdgeInsets.all(20.0),
            ),
          ],
        ),
      ),
    );
  }
}
