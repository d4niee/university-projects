import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/weather.dart';

/*
responsible for http calls to the openweatherapi
 */
class WeatherApi {

  final String API_KEY = "39900344c7e366a44d0138b205fc0164";
  final String endpoint = "https://api.openweathermap.org/data/2.5/forecast?";

  Future<dynamic> fetchForecast(String lat, String lon) async {
    print("fetching weather");
    // api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    // icon irl
    // https://openweathermap.org/weather-conditions
    var url = Uri.parse(endpoint + "lat=$lat&lon=$lon&appid=$API_KEY&units=metric");
    //var url = Uri.parse(endpoint + "lat=$lat&lon=$lon&cnt=3&appid=$API_KEY&units=metric");  limitation of results
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response return
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather');
    }
  }

}

