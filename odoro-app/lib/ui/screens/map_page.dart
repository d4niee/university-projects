import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/providers/map_controller.dart';
import 'package:odoro/core/providers/settings_controller.dart';
import 'package:odoro/ui/widgets/location_details_card.dart';
import 'package:provider/provider.dart';
import '../../core/providers/selection_controller.dart';
import '../../models/route_model.dart';
import '../widgets/create_marker_card.dart';
import '../widgets/create_route_card.dart';
import '../widgets/route_details_card.dart';

/*
the apps map screen where the user places markers to create new points of interest,
can track his path or look at existing markers
 */
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final position = Provider.of<LatLng>(context);
    final selection = Provider.of<SelectionProvider>(context);

    return ChangeNotifierProvider<MapController>(
        create: (context) {
          final controller = MapController(settings.defaultZoom);
          // TODO center on last selected route
          // TODO if point selescted, center on point
          // TODO clear selection mit button auf appbar verbinden
          // chosen route to map
          for(MapRoute route in selection.selectedMapRoutes) {
            var poly = controller.routeToPolyline(route);
            controller.setPolylines(poly);
            print("set polylines: ${controller.polylines}");
          }
          return controller;
        },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,

        body: Stack(
          children: [
            Consumer2<MapController, SettingsController>(
              builder: (context, mapController, settingsController, child) {
                print("buidling map");
                return GoogleMap(
                  zoomControlsEnabled: false,
                  markers: mapController.markers,
                  polylines: mapController.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: mapController.onMapCreated,
                  initialCameraPosition: mapController.initialCameraPosition,
                  onLongPress: mapController.onLongPress,
                  onTap: (pos) => mapController.onMapTapped(),
                );
              },
            ),
            Consumer<MapController>(
              builder: (context, mapController, child) {
                return StreamBuilder<Marker>(
                  stream: mapController.onMarkerTap,
                  builder: (context, AsyncSnapshot<Marker> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print("waiting for create marker data");
                    } else if (snapshot.connectionState == ConnectionState.active
                        || snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        print('Error in createmarkerstreambuilder');
                      } else if (snapshot.hasData) {
                        final Marker marker = snapshot.data!;
                        print("Streambuilder id: ${marker.markerId}");
                        return CreateMarker(marker: marker);
                      } else {
                        print('Empty data');
                      }
                    } else {
                      print('State: ${snapshot.connectionState}');
                    }
                    // no null return
                    return Card();
                  },
                );
              }
            ),
            Consumer<MapController>(
                builder: (context, mapController, child) {
                  return StreamBuilder<Polyline>(
                    stream: mapController.onSaveRoute,
                    builder: (context, AsyncSnapshot<Polyline> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        print("waiting for create route data");
                      } else if (snapshot.connectionState == ConnectionState.active
                          || snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          print('Error in createroutestreambuilder');
                        } else if (snapshot.hasData) {
                          final Polyline polyline = snapshot.data!;
                          print("Streambuilder polyline id: ${polyline.polylineId}");
                          return CreateRoute(polyline: polyline);
                        } else {
                          print('Empty data');
                        }
                      } else {
                        print('State: ${snapshot.connectionState}');
                      }
                      // no null return
                      return Card();
                    },
                  );
                }
            ),
            // TODO: Info window here if not _creating show poi in mapcontroller
            Consumer<MapController>(
              builder: (context, mapController, child) {
                final poi = mapController.tappedPointOfInterest;
                if(poi != null) {
                  return SafeArea(
                    child: LocationDetails(pointOfInterest: poi),
                  );
                }
                return SafeArea(child: Card());
              },
            ),
            Consumer<MapController>(
              builder: (context, mapController, child) {
                final line = mapController.tappedMapRoute;
                if(line != null) {
                  return SafeArea(
                    child: RouteDetails(route: line),
                  );
                }
                return SafeArea(child: Card());
              },
            ),
          ],
        ),

        floatingActionButton: Consumer<MapController>(
          builder: (_, controller, __) {
            return FloatingActionButton(
                tooltip: 'Center on me',
                child: const Icon(Icons.location_searching_outlined),
                onPressed: () {
                    controller.centerCamera(LatLng(position.latitude, position.longitude));
              }
            );
          }
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          color: Color.fromRGBO(65, 175, 151, 1.0),
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Consumer<MapController>(
                builder: (context, mapController, child) {
                  return (mapController.isRecording || mapController.currentPolyline == null )
                      ? const IconButton(
                          icon: Icon(Icons.save_alt_outlined, color: Colors.grey),
                          onPressed: null,
                        )
                      : IconButton(
                          icon: const Icon(Icons.save_alt_outlined, color: Colors.white),
                          onPressed: () {
                            mapController.openCreateRoute();
                          },
                      );
                  }
              ),
              Padding(
                child: Consumer<MapController>(
                  builder: (context, mapController, child) {
                    return IconButton(
                    icon: (mapController.isRecording)
                        ? const Icon(Icons.stop_circle_outlined, color: Colors.white)
                        : const Icon(Icons.route_outlined, color: Colors.white),
                    onPressed: () {
                      if(mapController.isRecording) {
                        showAlertDialog(context, mapController);
                      } else {
                        mapController.initLocationUpdates();
                      }
                      setState((){}) ;
                    },
                    tooltip: "Start tracking your route",
                  );
                  },
                ),
                padding: const EdgeInsets.only(right: 50),
              ),
              Padding(
                child: IconButton(
                  icon: const Icon(Icons.location_on_outlined, color: Colors.white,),
                  onPressed: () {
                  },
                  tooltip: "Toggle Markers",
                ),
                padding: const EdgeInsets.only(left: 50),
              ),
              IconButton(
                icon: const Icon(Icons.location_history_outlined, color: Colors.white,),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  used in route saving stuff
   */
showAlertDialog(BuildContext context, MapController controller) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed:  () {
      // do nothing, keep tracking
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: Text("Yes"),
    onPressed:  () {
      // stop recording
      print("pressed yes");
      controller.stopLocationUpdates();
      Navigator.of(context).pop();
    },
  );
  AlertDialog alert = AlertDialog(
    title: Text("Wait..."),
    content: Text("Do you really want to stop recording this route?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}