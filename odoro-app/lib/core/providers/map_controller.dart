import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/helpers/asset_to_bytes.dart';
import 'package:odoro/core/services/pointofinterest_service.dart';
import 'package:location/location.dart';
import 'package:odoro/core/services/route_service.dart';
import 'package:odoro/models/pointofinterest_model.dart';

import '../../models/route_model.dart';


/*
controls the maps state
set map style:
https://www.youtube.com/watch?v=7zLQQB5IKdc
images as markers:
https://www.youtube.com/watch?v=jHA-rwQbf3M
location permissions android and ios:
https://www.youtube.com/watch?v=bRyc6QLkckw
TODO: zoomhandling
https://stackoverflow.com/questions/55968628/google-maps-flutter-zoom-in-zoom-out
 */
class MapController with ChangeNotifier {

  // camera
  double zoom;
  late CameraPosition initialCameraPosition;

  // https://github.com/flutter/plugins/blob/master_archive/packages/google_maps_flutter/google_maps_flutter/example/lib/place_marker.dart
  // Marker --------------------------------------------------------------------
  final Map<MarkerId, Marker> _markerMap = {};
  Set<Marker> get markers => _markerMap.values.toSet();

  // database service for markers
  final pointOfInterestService = PointOfInterestService();
  final mapRouteService = MapRouteService();

  // stream of markers
  final _markersController = StreamController<Marker>.broadcast();
  Stream<Marker> get onMarkerTap => _markersController.stream;
  Marker? _lastCreated;

  // custom icon
  final _markerIcon = Completer<BitmapDescriptor>();

  // use this to load correct PoI from db
  MarkerId? selectedMarkerId;
  PointOfInterest? tappedPointOfInterest; // to open details
  PointOfInterest? selectedPointOfInterest; // loaded from selection provider

  bool _creating = false;
  bool get creating => _creating;

  bool _loading = true;
  bool get loading => _loading;

  // https://github.com/flutter/plugins/blob/master_archive/packages/google_maps_flutter/google_maps_flutter/example/lib/place_polyline.dart
  // polyline route and tracking -----------------------------------------------
  Map<PolylineId, Polyline> _polylines = {};
  Set<Polyline> get polylines => _polylines.values.toSet();
  void setPolylines(Polyline poly) {_polylines[poly.polylineId] = poly;}

  final _routeController = StreamController<Polyline>.broadcast();
  Stream<Polyline> get onSaveRoute => _routeController.stream;

  // database service for route saving
  MapRouteService routeService = MapRouteService();

  Polyline? currentPolyline; // being recorded
  MapRoute? tappedMapRoute; // details being shown
  List<LatLng> pointsOfCurrentPolyLine = [];

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isCreatingRoute = false;
  bool get isCreatingRoute => _isCreatingRoute;



  StreamSubscription<LocationData>? _positionSubscription;
  StreamSubscription<LocationData>? get positionSubscription => _positionSubscription;

  MapRoute? selectedMapRoute;
  List<MapRoute> chosenMapRoutes= [];

  // map controller reference to animate camera etc.
  late GoogleMapController _controllerReference;


  MapController(this.zoom) {
    // load map with default zoom from settings
    print("setting const camera");
    initialCameraPosition = CameraPosition(target: const LatLng(48.483334, 9.216667), zoom: zoom);
    _init();
  }


  Future<void> _init() async {
    // create the markerIcon
    final value = await assetToBytes("assets/marker_orange.png", width: 150);
    final bitmap = BitmapDescriptor.fromBytes(value);
    _markerIcon.complete(bitmap);
    // widget is ready
    _loading = false;
    //  TODO load markers
    await loadMarkers();
    // TODO load polyline or marker from selection, marker has precedence on carmera -> maybe in init()?
    if(selectedPointOfInterest != null) {
      print("loading selected poi in mc: $selectedPointOfInterest");
      centerCamera(LatLng(selectedPointOfInterest!.latitude, selectedPointOfInterest!.longitude));
      print("opening selected marker details");
      await _onMarkerTapped(MarkerId(selectedPointOfInterest!.markerId));
      print("details?");
    } else {
      print("-----------------------------------------------------selected poi is null");
      final lastKnownPosition = await Location().getLocation();
      centerCamera(LatLng(lastKnownPosition.latitude!, lastKnownPosition.longitude!));
    }
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    // TODO: take mapstyle from settings
    // controller.setMapStyle(mapStyle);
    _controllerReference = controller;
  }

  // Marker handling

  /*
  create a new marker when pressing the map at the pressed location
   */
  void onLongPress(LatLng position) async {
    tappedPointOfInterest = null;
    if(!_creating) {
    // id is number of markers, just needs to be unique
    final icon = await _markerIcon.future;
    final String id = position.latitude.toString() + position.longitude.toString();
    final MarkerId markerId = MarkerId(id);
    final Marker newMarker= Marker(
      markerId: markerId,
      position: position,
      // set custom marker icon
      icon: icon,
      onTap: () => _onMarkerTapped(markerId),
    );
    _markersController.sink.add(newMarker);
    _markerMap[markerId] = newMarker;
    _lastCreated = newMarker;
    _creating = true;
    // center camera on new marker
    centerCamera(position);
    notifyListeners();
    }
  }

  cancelMarker(Marker marker) {
    _creating = false;
    final markerIdToRemove = marker.markerId;
    _markerMap.remove(markerIdToRemove);
    notifyListeners();
  }

  storeMarker(PointOfInterest pointOfInterest) async {
    await pointOfInterestService.createPointOfInterest(pointOfInterest);
    print("stored succesfully");
    _creating = false;
    notifyListeners();
  }

  // https://github.com/flutter/plugins/blob/master_archive/packages/google_maps_flutter/google_maps_flutter/example/lib/place_marker.dart
  Future<void> loadMarkers() async {
    // change it so marker gets created here for custom icon?
    final icon = await _markerIcon.future;
    final pointsOfInterest = await pointOfInterestService.getAllPointsOfInterest();
    for(PointOfInterest pointOfInterest in pointsOfInterest) {
      final marker = poiToMarker(pointOfInterest, icon);
      _markerMap[MarkerId(pointOfInterest.markerId)] = marker;
    }
    notifyListeners();
  }

  /*
  opens info window of tapped marker
   */
  Future<void> _onMarkerTapped(MarkerId markerId) async {
    tappedPointOfInterest = null;
    if(_creating) {
      return;
    }
    final pointOfInterest = await pointOfInterestService.getPointOfInterestWhereKeyValue(
        "markerId", markerId.value);
    // returns list but only contains one value
    if (pointOfInterest.length > 0) {
      tappedPointOfInterest = pointOfInterest[0];
      centerCamera(LatLng(tappedPointOfInterest!.latitude,
          tappedPointOfInterest!.longitude));
    }
    notifyListeners();
  }

  // Route Handling
  /*
  start tracking position
   */
  void initLocationUpdates() async {
    if (currentPolyline == null) {
      final locService = Location();
      LocationData position = await locService.getLocation();
      PolylineId polylineId = PolylineId(
          position.latitude.toString() + position.longitude.toString() + DateTime.now().toString()
      );
      print("generated polylione id: $polylineId");
      Polyline newPolyline = Polyline(
          polylineId: polylineId,
          points: pointsOfCurrentPolyLine,
          onTap: () => _onPolylineTapped(polylineId),
          width: 5,
          consumeTapEvents: true,
      );
      // TODO add new polyline to polyline map
      print("Current Polyline has id: ${newPolyline.polylineId.value}");
      _polylines[polylineId] = newPolyline;
      currentPolyline = newPolyline;
      print("Polylines Map: ${_polylines}");

      await locService.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 5000,
        distanceFilter: 10,
      );
      _isRecording = true;
      _positionSubscription = locService.onLocationChanged.listen(
            (LocationData position) {
          // update location and add to points;
              LatLng currentPosition = LatLng(position.latitude!, position.longitude!);
              centerCamera(currentPosition);
              pointsOfCurrentPolyLine.add(currentPosition);
              notifyListeners();
        },
        onError: (e) {
          print("error in location stream: ${e.runtimeType}");
        },
      );
    } else {
      // resume tracking
      print("already tracking, save first");

    }
  }

  openCreateRoute() {
    // TODO add check if marker creation window is open?
    _routeController.sink.add(currentPolyline!);
    _isCreatingRoute = true;
    notifyListeners();
  }

  stopLocationUpdates() {
    final _positionSubscription = this._positionSubscription;
    if(_positionSubscription != null) {
      _positionSubscription.cancel();
      notifyListeners();
    }
    _isRecording = false;
    notifyListeners();
  }

  cancelRoute() {
    _isCreatingRoute = false;
    notifyListeners();
  }

  Future<void> storeCurrentPolyline(MapRoute route) async {
    await routeService.createRoute(route);
    _isCreatingRoute = false;
    notifyListeners();
  }

  Future<void> _onPolylineTapped(PolylineId polylineId) async {
    tappedMapRoute = null;
    print("polyline tapped");
    final routes = await mapRouteService.getMapRouteWhereKeyValue(
        "polylineId", polylineId.value);
    // returns list but only contains one value
    if (polylines.length > 0) {
      tappedMapRoute = routes[0];
      print("$tappedMapRoute");
      centerCamera(LatLng(
        tappedMapRoute!.routePoints[0].latitude,
        tappedMapRoute!.routePoints[0].longitude,
      ));
    }
    notifyListeners();
  }

  void removeCurrentPolyline(Polyline polyline) {
    final polylineToRemove = polyline.polylineId;
    _polylines.remove(polylineToRemove);
    currentPolyline = null;
    _isCreatingRoute = false;
    notifyListeners();
  }

  // helper methods
  centerCamera(LatLng position) {
    // make zoom respond to current zoom level of map
    _controllerReference.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: position,
                zoom: zoom,
            )
        )
    );
  }

  Polyline routeToPolyline(MapRoute mapRoute) {
    final id = PolylineId(mapRoute.polylineId);
    return Polyline(
      polylineId: id,
      points: mapRoute.routePoints,
      width: 5,
      onTap: () => _onPolylineTapped(id),
      consumeTapEvents: true,
    );
  }

  Marker poiToMarker(PointOfInterest poi, BitmapDescriptor icon) {
    return Marker(
        markerId: MarkerId(poi.markerId),
        position: LatLng(poi.latitude, poi.longitude),
        icon: icon,
        onTap: () {
            _onMarkerTapped(MarkerId(poi.markerId));
          },
    );
  }

  onMapTapped() {
    print("map tapped");
    // when tapping map and creation dialog open => cancelCreating
    if(_creating) {
      cancelMarker(_lastCreated!);
    }
    // if marker selected => info window open set null
    if(tappedPointOfInterest != null) {
      tappedPointOfInterest = null;
    }
    if(tappedMapRoute != null) {
      tappedMapRoute = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }
}