/*
makes use of a weather api to get needed data for app
 */
import 'package:odoro/core/api/weather_api.dart';
import 'package:odoro/models/weather.dart';

/*
uses a weather api to get weather data needed in the app
 */
class WeatherService {
  late final WeatherApi weatherApi;

  WeatherService() {
    weatherApi = WeatherApi();
  }

  Future<List<Weather>> getForecast(String lat, String lon) async {
    final response = await weatherApi.fetchForecast(lat, lon);
    final weatherData = response["list"];
    List<Weather> forecast = [];
    for(Map<String, dynamic> value in weatherData) {
      final weather = Weather.fromJson(value);
      forecast.add(weather);
    }
    return forecast;
  }

  Future<Weather> getCurrentWeather(String lat, String lon) async {
    print("get weather at marker...");
    final weather = await getForecast(lat, lon);
    return weather[0];
  }

}
