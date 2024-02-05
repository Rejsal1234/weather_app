import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/utils/colors.dart';
import 'package:weather_app/weather.dart';

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
  final weather = LocationWeather();

  Future<void> _currentLocation() async {
    await weather.callCurrentPosition();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _currentLocation();
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
      child: weather.loading
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
                    weather.currentWeather?.name?.toString() ?? "",
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
                      weather.currentWeather?.main?.temp?.toString() ?? "",
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
