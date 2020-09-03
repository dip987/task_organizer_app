import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sample_test_3/pages/home_page.dart';
import 'package:flutter_sample_test_3/pages/profile_page.dart';
import 'package:flutter_sample_test_3/pages/add_page.dart';


void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataProvider>(
      create: (_) {
        var _provider = DataProvider();
        _provider.init();
        return _provider;
      },
      builder: (BuildContext context, Widget child) {
        //Check to see if the values have loaded yet
        if (Provider.of<DataProvider>(context).colorConstants != null) return child;
        //Wait while the things load and show a white background?
        else return Container(color: Colors.white,);
      },
      child: MaterialApp(
        routes: {
          '/home': (context) => HomePage(),
          '/add': (context) => AddPage(),
          '/profile': (context) => ProfilePage()
        },
        title: 'TODO App for Non-weaboos',
        theme: ThemeData(
          textTheme: GoogleFonts.oswaldTextTheme(),
          //TODO Save fonts on device first
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/home',
        //TODO Study about String Distance Algorithms
      ),
    );
  }
}

