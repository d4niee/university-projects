import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/providers/map_controller.dart';
import 'package:odoro/models/pointofinterest_model.dart';
import 'package:provider/provider.dart';


class CreateMarker extends StatefulWidget {

  final Marker marker;
  const CreateMarker({required this.marker, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateMarkerState();
}

class _CreateMarkerState extends State<CreateMarker> {

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
        return (mapController.creating)
        ? SafeArea(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    leading: Icon(Icons.add_location_alt_outlined),
                    title: Text("New Point of Interest"),
                    subtitle: Text("Enter the necessary details for this place"),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border:  OutlineInputBorder(),
                      labelText: "Name the Location",
                    ),
                  ),
                  const SizedBox(height: 15,),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border:  OutlineInputBorder(),
                      labelText: "Describe the Location",
                    ),
                  ),
                  ButtonBar(
                    //alignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // cancel button
                      TextButton(
                          onPressed: () {
                            mapController.cancelMarker(widget.marker);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Point of Interest was not stored",
                                      textAlign: TextAlign.center,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                              )
                            );
                          },
                          child: const Text("Cancel")
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
                          final pointOfInterest = PointOfInterest(
                              pointOfInterestName: name,
                              pointOfInterestDescription: description,
                              latitude: widget.marker.position.latitude,
                              longitude: widget.marker.position.longitude,
                              markerId: widget.marker.markerId.value,
                              userName: fireBaseUser.displayName!,
                          );
                          await mapController.storeMarker(pointOfInterest);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Point of Interest has been saved",
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