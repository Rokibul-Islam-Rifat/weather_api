import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // this section is for geolocator packages
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // this is the part converted to variable position
    position = await Geolocator.getCurrentPosition();
    var lo = position!.longitude;
    var lat = position!.latitude;
    print("Longitude${lo}");
    print("Latiude${lat}");
    getWeatherData();
  }

  Position? position;
  // this section is for initstate for geolocator determinePosition
  @override
  void initState() {
    determinePosition();
    super.initState();
  }

  // this section is for wather Maping
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? foreCastMap;
  // this section is for weather url
  getWeatherData() async {
    var weatherUl =
        "https://api.openweathermap.org/data/2.5/weather?lat=${position?.latitude}&lon=${position?.longitude}&appid=047437b069dd6c62cd5753024a154e18";
    var foreCastUl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position?.latitude}&lon=${position?.longitude}&appid=047437b069dd6c62cd5753024a154e18";
    var weatherData = await http.get(Uri.parse(weatherUl));
    print("Weather Data${weatherData.body}");
    var foreCastData = await http.get(Uri.parse(foreCastUl));
    print("Forecast Data${foreCastData.body}");

    var wathers = jsonDecode(weatherData.body);
    var forecasts = jsonDecode(foreCastData.body);
    setState(() {
      weatherMap = Map<String, dynamic>.from(wathers);
      foreCastMap = Map<String, dynamic>.from(forecasts as Map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: weatherMap != null
          ? Scaffold(
              body: Column(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      children: [
                        Text(
                            "${Jiffy.parse("${DateTime.now()}").format(pattern: 'MMMM do yyyy, h:mm:ss a')}"),
                        Text("${weatherMap?["name"]}"),
                      ],
                    ),
                  ),
                  Image.network(
                      "https://openweathermap.org/img/wn/${weatherMap!["weather"][0]["icon"]}@2x.png"),
                  Text("${weatherMap?["main"]["temp"]}"),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      children: [
                        Text("Feels like${weatherMap?["main"]["feels_like"]}"),
                        Text("${weatherMap?["weather"][0]["description"]}"),
                      ],
                    ),
                  ),
                  Text(
                      "Humidity ${weatherMap?["main"]["humidity"]}, Pressure${weatherMap?["main"]["pressure"]}"),
                  Text(
                      "Sunrise${Jiffy.parse('${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}').format(pattern: ' h:mm:ss a')},Sunset${Jiffy.parse('${DateTime.fromMicrosecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}').format(pattern: ' h:mm:ss a')}"),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: foreCastMap?.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.amber,
                            margin: EdgeInsets.only(right: 10),
                            child: Column(
                              children: [
                                Text(
                                    "${Jiffy.parse('${foreCastMap!["list"][index]["dt_txt"]}').format(pattern: 'MMMM do yyyy')}"),
                                // Text(
                                //     "${Jiffy.parse('2021/01/19').format(pattern: 'MMMM do yyyy')}"),
                                Image.network(
                                    "https://openweathermap.org/img/wn/${foreCastMap!["list"][index]["weather"][0]["icon"]}@2x.png"),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
