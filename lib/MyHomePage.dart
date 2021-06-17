import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int temperature = 0;
  int woeid = 1521894;
  String location = 'City';
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';
  String weather = 'clear';
  String abbreviation = '';
  String errorMessage = '';

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
        print(location);
      });
    } catch (error) {
      setState(() {
        errorMessage =
            "Sorry, we don't have data about this city. Try another one.";
      });
    }
  }

  void fetchLocation() async {
    var locationresult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationresult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];
    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(" ", "").toLowerCase();
      abbreviation = data["weather_state_abbr"];
      print(weather + temperature.toString());
    });
  }

  void onTextFieldSubmitted(String input) {
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/$weather.png"), fit: BoxFit.cover)),
          child: temperature == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.network(
                            "https://www.metaweather.com/static/img/weather/png/$abbreviation.png",
                            width: 100,
                          ),
                          Center(
                            child: Text(
                              temperature.toString() + ' °C',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 60.0),
                            ),
                          ),
                          Center(
                            child: Text(
                              location,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 40.0),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 300,
                            child: TextField(
                              onSubmitted: (input) {
                                onTextFieldSubmitted(input);
                              },
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                              decoration: InputDecoration(
                                  hintText: 'Search another location...',
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 32.0, left: 32.0),
                            child: Text(errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize:
                                        Platform.isAndroid ? 15.0 : 20.0)),
                          )
                        ],
                      )
                    ],
                  ),
                )),
    );
  }
}
