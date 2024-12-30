import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherController extends GetxController {
  var selectedDistrict = 'omalur'.obs;
  var data = {}.obs;

  @override
  void onInit() {
    super.onInit();
    getData(selectedDistrict.value);
  }

  void updateDistrict(String district) {
    selectedDistrict.value = district;
    getData(district);
  }

  Future<void> getData(String district) async {
    final url = "https://api.openweathermap.org/data/2.5/weather?q=$district&appid=f54b9b7592e56ef0e3110c8987eb0cd9";
   // final res = await http.get(Uri.parse(url));
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'district': district}),
    );

    if (res.statusCode == 200) {
      data.value = jsonDecode(res.body);
      DateTime sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
      String formattedSunrise = DateFormat('hh:mm a').format(sunrise);
      data['sys']['sunrise'] = formattedSunrise;

      // Convert and format sunset time
      DateTime sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
      String formattedSunset = DateFormat('hh:mm a').format(sunset);
      data['sys']['sunset'] = formattedSunset;

    } else {
      data.value = {'error': 'City not found'};
    }
  }
}
