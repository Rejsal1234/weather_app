import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationWeather {
  Map<String, dynamic>? _currentWeather;
  bool _loading = false;

  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get loading => _loading;

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
            "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=9acc6142fab318f48384290c4edb2491&units=metric"),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        _currentWeather = jsonDecode(res.body) as Map<String, dynamic>?;
      } else {
        final error = jsonDecode(res.body) as Map<String, dynamic>?;
        throw error?["message"] ??
            error?["error"] ??
            "Unexpected error occurred";
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> callCurrentPosition() async {
    _loading = true;
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
    _loading = false;
  }
}
