import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/utils/colors.dart';

void main() {
  runApp(
    const WeatherApp(),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Weather(),
        ),
      ),
    );
  }
}

class Weather extends StatefulWidget {
  const Weather({super.key});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Map<String, dynamic>? _currentWeather;
  bool _loading = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw 'Location services are disabled.';
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
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw 'Location permissions are permanently denied, we cannot request permissions. Please go to app settings.';
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      final position = await Geolocator.getCurrentPosition();
      final res = await http.get(
        Uri.parse(
            "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=03a0de2a0e404a5ba777067b1fc94e35&units=metric"),
      );
      setState(() {
        _currentWeather = jsonDecode(res.body) as Map<String, dynamic>?;
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _callCurrentPosition() async {
    setState(() {
      _loading = true;
    });
    try {
      await _getCurrentLocation();
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _callCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, whiteColor],
        ),
      ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentWeather?['name'],
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 40,
                        color: whiteColor),
                  ),
                  const SizedBox(
                    height: 100.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      _currentWeather?['main']['temp'].toString() ?? "Loading",
                      style: GoogleFonts.poppins(
                        fontSize: 76,
                        fontWeight: FontWeight.w400,
                        color: whiteColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
