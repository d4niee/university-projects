import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/services/user_database_service.dart';
import 'package:odoro/models/user_favourites.dart';
import 'package:odoro/ui/widgets/favourites_list_card.dart';
import 'package:provider/provider.dart';

class Favourites extends StatelessWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    UserDataBaseService userDB =
        UserDataBaseService(userUID: firebaseUser.uid.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourites"),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                userDB.deleteAllFavourites();
              })
        ],
      ),
      body: Center(
        child: FutureBuilder<List<UserFavourites>>(
          future: userDB.getUserFavourites(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final fav = snapshot.data![index];
                  return FavouriteListCard(favourites: fav);
                },
              );
            } else if (snapshot.hasError) {
              return Text("{$snapshot.error}");
            }
            return const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
