import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/providers/selection_controller.dart';
import 'package:odoro/core/routes/route_generator.dart';
import 'package:odoro/core/services/user_database_service.dart';
import 'package:odoro/models/pointofinterest_model.dart';
import 'package:odoro/models/user_favourites.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:provider/provider.dart';

class LocationListCard extends StatelessWidget {
  final PointOfInterest pointOfInterest;
  final SelectionProvider selectionProvider = SelectionProvider();
  LocationListCard({required this.pointOfInterest, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final firebaseUser = context.watch<User>();
    UserDataBaseService service =
        UserDataBaseService(userUID: firebaseUser.uid);
    return Card(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
          onTap: () {
            // TODO: add to selection and confirm in snackbar, switch to map
            selectionProvider.selectPointOfInterest(pointOfInterest);
            print("selected marker $pointOfInterest");
            // TODO open map with a navigator call
            Navigator.pushNamed(context, RouteGenerator.mapPage);
          },
          leading: CircleAvatar(
              backgroundColor: MyColorTheme.primaryGreyShade,
              child: Image.asset("assets/marker_orange.png")),
          title: Text("Location: ${pointOfInterest.pointOfInterestName}"),
          subtitle: Text(
              "Lat: ${pointOfInterest.latitude.toStringAsFixed(2)} Lon: ${pointOfInterest.longitude.toStringAsFixed(2)}"),
          trailing: IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () {
                UserFavourites fav = UserFavourites(
                    title: pointOfInterest.pointOfInterestName,
                    latitude: pointOfInterest.latitude,
                    longitude: pointOfInterest.longitude,
                    desc: pointOfInterest.pointOfInterestDescription);
                service.addUserFavourite(favourites: fav).then((value) {
                  debugPrint("added to favourites!");
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "added to Favourites!",
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                  ));
                });
              }),
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(pointOfInterest.pointOfInterestDescription)),
      ],
    ));
  }
}
