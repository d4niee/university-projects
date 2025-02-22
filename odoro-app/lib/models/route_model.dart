// https://pub.dev/documentation/google_maps_flutter_platform_interface/latest/google_maps_flutter_platform_interface/LatLng-class.html
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/models/data_model.dart';

/*
represents a route traveled by a user
 */
class MapRoute implements DataModel {
  final String routeName;
  final String routeDescription;
  //int? routeRating;
  final String polylineId;
  List<LatLng> routePoints;
  final double routeDistance;
  // final duration;
  final String routeAuthor;

  MapRoute({
    required this.routeName,
    required this.routeDescription,
  //this.routeRating,
    required this.polylineId,
    required this.routePoints,
    required this.routeDistance,
    required this.routeAuthor,
  });

  // TODO list<LatLng> and DateTime serialization / deserialization
  @override
  Map<String, dynamic> toJson() {
    List<Map<String, double>> jsonRoute = [];
    for(LatLng point in routePoints) {
      Map<String, double> latlon = {
        "latitude": point.latitude,
        "longitude": point.longitude
      };
      jsonRoute.add(latlon);
    }

    return <String, dynamic>{
      "routeName": routeName,
      "routeDescription": routeDescription,
      //"routeRating": routeRating,
      "routeDistance": routeDistance,
      "author": routeAuthor,
      "routePoints": jsonRoute,
      "polylineId": polylineId,
    };
  }

  factory MapRoute.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot
      ) {
    final data = snapshot.data();
    final jsonRoute = data?["routePoints"];
    List<LatLng> route = [];
    for(var point in jsonRoute) {
      LatLng newPoint = LatLng(point["latitude"]!, point["longitude"]!);
      route.add(newPoint);
    }
    return MapRoute(
        routeName: data?["routeName"],
        routeDescription: data?["routeDescription"],
        //routeRating: data?["rating"],
        polylineId: data?["polylineId"],
        routePoints: route,
        routeDistance: data?["routeDistance"],
        routeAuthor: data?["author"],
    );  }
}