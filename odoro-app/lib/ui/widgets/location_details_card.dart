import 'package:flutter/material.dart';
import 'package:odoro/core/services/weather_service.dart';
import 'package:odoro/models/pointofinterest_model.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:odoro/ui/widgets/weather_card.dart';
import '../../models/weather.dart';
/*
container to display information about a point of interest
 */
class LocationDetails extends StatefulWidget {
  final PointOfInterest pointOfInterest;

  LocationDetails({required this.pointOfInterest, Key? key}) : super(key: key);

  @override
  State<LocationDetails> createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  final weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Name: ${widget.pointOfInterest.pointOfInterestName}"),
            subtitle: Text("By: ${widget.pointOfInterest.userName}"),
            // trailing: Text(pointOfInterest.rating.toStringAsFixed(1)),
          ),
          const Divider(
            color: MyColorTheme.primaryDarkestShade,
            thickness: 0.5,
            indent: 15,
            endIndent: 15,
          ),
          Padding(
            child: Text(widget.pointOfInterest.pointOfInterestDescription),
            padding: const EdgeInsets.all(20),
          ),
          FutureBuilder<Weather>(
              future: weatherService.getCurrentWeather(
                  widget.pointOfInterest.latitude.toString(),
                  widget.pointOfInterest.longitude.toString()),
              builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return WeatherCard(weather: snapshot.data!);
                  } else if(snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator());
                  }
              }
          ),
        ],
      ),
    );
  }
}