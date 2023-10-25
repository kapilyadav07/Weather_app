import "dart:convert";
import "dart:ui";
import "package:flutter/material.dart";
import 'package:weather_app/additonal_info.dart';
import "package:weather_app/hourlyfoCastItem.dart";
import "package:http/http.dart" as http;
import "package:weather_app/secret.dart";

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getWeather() async {
    try {
      String cityname = "London";
      final res = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$weatherKey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data["cod"] != "200") {
        throw data["message"];
      }
      return data;

      //temp = data["list"][0]["main"]["temp"];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Weather App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: FutureBuilder(
            future: getWeather(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              final data = snapshot.data!;
              final currentWeather = data["list"][0];
              final currentTemp = currentWeather["main"]["temp"];
              final currentSky = currentWeather["weather"][0]["main"];
              final currentPressure = currentWeather["main"]["pressure"];
              final currentHumadity = currentWeather["main"]["humidity"];
              final currentWindSpeed = currentWeather["wind"]["speed"];

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //main cart
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp K",
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Icon(
                                currentSky == "Clouds" || currentSky == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentSky.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //weather forecast cards
                    const Text(
                      "Hourly Forecast",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            HourlyForecastItem(
                              time: data["list"][i + 1]["dt"].toString(),
                              icon: data["list"][i + 1]["weather"][0]["main"] ==
                                          "Clouds" ||
                                      data["list"][i + 1]["weather"][0]
                                              ["main"] ==
                                          "Rain"
                                  ? Icons.cloud
                                  : Icons.sunny,
                              temperature: data["list"][i + 1]["main"]["temp"]
                                  .toString(),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ADDITINALINFO(
                          icon: Icons.water_drop,
                          label: "Humadity",
                          value: currentHumadity.toString(),
                        ),
                        ADDITINALINFO(
                            icon: Icons.air,
                            label: "Wind Speed",
                            value: currentWindSpeed.toString()),
                        ADDITINALINFO(
                            icon: Icons.beach_access,
                            label: "Pressure",
                            value: currentPressure.toString()),
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
