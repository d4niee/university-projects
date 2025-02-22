import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/services/weather_service.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:odoro/ui/widgets/weather_card.dart';
import 'package:provider/provider.dart';
import '../../models/weather.dart';

class Forecast extends StatefulWidget {
  const Forecast({Key? key}) : super(key: key);

  @override
  _CurrentWeather createState() => _CurrentWeather();
}

class _CurrentWeather extends State<Forecast> {
  WeatherService weatherService = WeatherService();
  late LatLng position;
  late List<Weather> weatherData;

  @override
  Widget build(BuildContext context) {
    position = Provider.of<LatLng>(context);
    return Center(
      child: FutureBuilder<List<Weather>>(
        future: weatherService.getForecast(position.latitude.toString(), position.longitude.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const Divider(color: MyColorTheme.primaryDarkestShade, thickness: 0.2, indent: 15, endIndent: 15,),
                itemBuilder: (BuildContext context, int index) {
                  final weather = snapshot.data![index];
                  return WeatherCard(weather: weather);
                  },
              );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator());
        },
      ),
    );
  }
}
