import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/services/user_database_service.dart';
import 'package:odoro/models/user_favourites.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:provider/provider.dart';

class FavouriteListCard extends StatelessWidget {
  final UserFavourites favourites;
  const FavouriteListCard({required this.favourites, Key? key})
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
          leading: CircleAvatar(
              backgroundColor: MyColorTheme.primaryGreyShade,
              child: Image.asset("assets/marker_orange.png")),
          title: Text("Location: ${favourites.title}"),
          subtitle: Text(
              "Lat: ${favourites.latitude.toStringAsFixed(2)} Lon: ${favourites.longitude.toStringAsFixed(2)}"),
        ),
        Padding(
            padding: const EdgeInsets.all(10), child: Text(favourites.desc)),
      ],
    ));
  }
}
