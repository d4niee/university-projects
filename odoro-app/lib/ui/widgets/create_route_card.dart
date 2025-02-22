import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as LL;
import 'package:odoro/core/providers/map_controller.dart';
import 'package:provider/provider.dart';

import '../../models/route_model.dart';


class CreateRoute extends StatefulWidget {

  final Polyline polyline;
  const CreateRoute({required this.polyline, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateRouteState();
}

class _CreateRouteState extends State<CreateRoute> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fireBaseUser = context.watch<User>();

    return Consumer<MapController>(
        builder: (context, mapController, child) {
          return (mapController.isCreatingRoute)
            ? SafeArea(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.gesture_outlined),
                      title: Text("New Route"),
                      subtitle: Text("Enter the necessary details for this route"),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border:  OutlineInputBorder(),
                        labelText: "Name the Route",
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border:  OutlineInputBorder(),
                        labelText: "Describe the way",
                      ),
                    ),
                    ButtonBar(
                      //alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // cancel button
                        TextButton(
                            onPressed: () {
                              // TODO what happens on cancel
                              mapController.cancelRoute();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Route was not stored",
                                      textAlign: TextAlign.center,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  )
                              );
                            },
                            child: const Text("Cancel")
                        ),

                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO clear route from routes map here
                            mapController.removeCurrentPolyline(widget.polyline);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Route has been removed",
                                    textAlign: TextAlign.center,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          },
                          label: const Text("Remove"),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        // save button
                        ElevatedButton.icon(
                          onPressed: () async {
                            // save to db, if successful show snackbar
                            String name = _nameController.text.trim();
                            String description = _descriptionController.text.trim();
                            print("name: ${name} desc: ${description}");
                            if(name == "" || description == "") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please put a name and description",
                                      textAlign: TextAlign.center,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  )
                              );
                              return;
                            }
                            LL.Distance distance = const LL.Distance();
                            double totalDistance = 0;
                            final routePoints = widget.polyline.points;
                            for(var i=0; i<routePoints.length; i++) {
                              if(i>0) {
                                totalDistance += distance(
                                LL.LatLng(routePoints[i-1].latitude, routePoints[i-1].longitude),
                                LL.LatLng(routePoints[i].latitude, routePoints[i].longitude));
                                print("dist: ${totalDistance} m");
                              }
                            }
                            final route = MapRoute(
                                routePoints: widget.polyline.points,
                                routeName: _nameController.text.trim(),
                                polylineId: widget.polyline.polylineId.value,
                                routeDescription: _descriptionController.text.trim(),
                                routeAuthor: fireBaseUser.displayName!,
                                routeDistance: totalDistance,
                            );
                            // TODO store route
                            await mapController.storeCurrentPolyline(route);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Route has been saved",
                                    textAlign: TextAlign.center,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                )
                            );
                          },
                          label: const Text("Save"),
                          icon: const Icon(Icons.save_alt_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
              : const SafeArea(child: Card());
        }
    );

  }

}