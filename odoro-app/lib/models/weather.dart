import 'package:odoro/models/data_model.dart';

/*
entity that represents weather
 */
class Weather implements DataModel{
  final double temp;
  final double feelsLike;
  final double low;
  final double high;
  final String description;
  final String icon;
  final String dateTime;

  Weather({
    required this.temp,
    required this.feelsLike,
    required this.low,
    required this.high,
    required this.description,
    required this.icon,
    required this.dateTime,
  });

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      "temp": temp,
      "feelsLike": feelsLike,
      "low": low,
      "high": high,
      "description": description
    };
  }

  factory Weather.fromJson(Map<String, dynamic> json){
    return Weather(
      temp: json["main"]["temp"].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      low: json['main']['temp_min'].toDouble(),
      high: json['main']['temp_max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      dateTime: json["dt_txt"],
    );
  }

  @override
  String toString() {
    return 'Weather{temp: $temp, feelsLike: $feelsLike, low: $low, high: $high, description: $description, icon: $icon}';
  }
}