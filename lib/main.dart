import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'weather_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  final WeatherController controller = Get.put(WeatherController());
  final weatherSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: weatherSearch,
              decoration: InputDecoration(hintText: 'Enter City ..'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {
                controller.updateDistrict(weatherSearch.text);
              },
              child: Text(
                'Search..',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Obx(() {
              if (controller.data.isEmpty) {
                return Text('Loading weather data...');
              } else if (controller.data.containsKey('error')) {
                return Text(
                  controller.data['error'],
                  style: TextStyle(fontSize: 18, color: Colors.red),
                );
              } else {
                // Calculate temperature in Celsius
                double tempCelsius = controller.data['main']['temp'] - 273.15;

                // Determine image based on temperature
                String tempImage;
                if (tempCelsius < 15) {
                  tempImage = 'assets/cold.png'; // Image for cold weather
                } else if (tempCelsius < 30) {
                  tempImage = 'assets/moderate.png'; // Image for moderate weather
                } else {
                  tempImage = 'assets/hot.png'; // Image for hot weather
                }

                // Weather icon from API
                final weatherIconCode = controller.data['weather'][0]['icon'];
                final weatherIconUrl =
                    "https://openweathermap.org/img/wn/$weatherIconCode@2x.png";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Weather icon from API
                    Image.network(
                      weatherIconUrl,
                      height: 100,
                      width: 100,
                    ),
                    // Suitable image for temperature
                    /*Image.asset(
                      tempImage,
                      height: 150,
                      width: 150,
                    ),*/
                    // Display temperature
                    Text(
                      'Temperature: ${tempCelsius.toStringAsFixed(1)} °C',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Weather description
                    Text(
                      'Condition: ${controller.data['weather'][0]['description']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Sunrise and sunset times
                    Text(
                      'Sunrise: ${controller.data['sys']['sunrise']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Sunset: ${controller.data['sys']['sunset']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
