import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/*
provdides methods for:
- getting one time value of current location
- a stream of the current location
https://medium.com/flutter-community/build-a-location-service-in-flutter-367a1b212f7a
https://stackoverflow.com/questions/62198049/how-to-create-a-flutter-background-service-that-works-also-when-app-closed

// https://pub.dev/packages/location
*/
class LocationService {

  late LatLng _currentLocation;
  Location location = Location();

  // returns the current user location
  Future<LatLng> getLocation() async {
    try {
      LocationData newLocation = await location.getLocation();
      _currentLocation = LatLng(newLocation.latitude!, newLocation.longitude!);
    } on Exception catch(e) {
      print("Error getting location");
    }
    return _currentLocation;
  }

  // TODO refactor to here from Map Controller
  // dynamic user position updates via a stream
  final StreamController<LatLng> _locationController = StreamController<LatLng>();
  Stream<LatLng> get locationStream => _locationController.stream;

  // returns a stream of the users changing position
  LocationService() {
    // TODO check and request permission to use location
    // TODO changeSettings of distance/ time value so only new value after certain time/ distance
    // listen to the onLocationChanged stream and emit over controller
    location.onLocationChanged.listen((LocationData locationData) {
      _locationController.add(
          LatLng(locationData.latitude!, locationData.longitude!)
      );
    });
  }

  // check and request service/ permission to use location
  void checkLocationEnabled() {

  }

  void permissionCheck() {

  }


}