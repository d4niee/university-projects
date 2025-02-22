import 'package:flutter/material.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:intl/intl.dart';


import '../../models/weather.dart';

class WeatherCard extends StatelessWidget {

  final Weather weather;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = dateFormat.parse(weather.dateTime);
    return
            ListTile(
                leading: CircleAvatar(
                    child: Image(image: NetworkImage("https://openweathermap.org/img/wn/${weather.icon}@2x.png")),
                    backgroundColor: MyColorTheme.primaryGreyShade,
                ),
                //title: Text("${weather.dateTime.substring(0,16).replaceAll("-", ".").replaceFirst(" ", ". ")}: ${weather.description}"),
                title: Text(DateFormat.MEd().add_j().format(dateTime), textAlign: TextAlign.start),
                subtitle: Text("High: ${weather.high.round()}°C, Low: ${weather.low.round()}°C"),
                trailing: Text("${weather.temp.round()}°C",
                              style: const TextStyle(fontWeight: FontWeight.bold,
                                                      fontSize: 30,
                              ),
                          )
            );
  }

}