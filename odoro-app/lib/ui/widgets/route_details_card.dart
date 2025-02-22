import 'package:flutter/material.dart';
import 'package:odoro/ui/widgets/weather_card.dart';
import '../../core/services/weather_service.dart';
import '../../models/route_model.dart';
import '../../models/weather.dart';

/*
shows details for the selected route
 */
class RouteDetails extends StatefulWidget {
  final MapRoute route;

  RouteDetails({required this.route, Key? key}) : super(key: key);

  @override
  State<RouteDetails> createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  final weatherService = WeatherService();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.route.routeName),
            subtitle: Text("By: ${widget.route.routeAuthor}     Distance: ${widget.route.routeDistance}m"),
            // trailing: Text(pointOfInterest.rating.toStringAsFixed(1)),
          ),
          Padding(
            child: Text(widget.route.routeDescription),
            padding: const EdgeInsets.all(20),
          ),
          FutureBuilder<Weather>(
              future: weatherService.getCurrentWeather(
                  widget.route.routePoints.first.latitude.toString(),
                  widget.route.routePoints.first.longitude.toString()),
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