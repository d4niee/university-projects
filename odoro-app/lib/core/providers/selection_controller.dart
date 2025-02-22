/*
contains selected point / route
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/models/pointofinterest_model.dart';

import '../../models/route_model.dart';


class SelectionProvider with ChangeNotifier {

  List<Polyline> chosenPolylines = [];
  Marker? chosenMarker;

  Set<MapRoute> selectedMapRoutes = {};
  PointOfInterest? selectedPointOfInterest;


  // clears all currently displayed routes from displaying on map
  void clearRouteSelection() {
    chosenPolylines = [];
    print("Routes cleared from map");
    notifyListeners();
  }

  //
  void addToPolylines(MapRoute mapRoute) {
    selectedMapRoutes.add(mapRoute);
    print("current route selection: $selectedMapRoutes");
    notifyListeners();
  }

  //
  void selectPointOfInterest(PointOfInterest pointOfInterest) {
    selectedPointOfInterest = pointOfInterest;
    print("current poi selection: $selectedPointOfInterest");
    notifyListeners();
  }


}