import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:odoro/models/user_favourites.dart';

class UserDataBaseService {
  final String userUID;
  UserDataBaseService({required this.userUID});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Future addUserFavourite({required UserFavourites favourites}) async {
    return await userCollection
        .doc(userUID)
        .collection("user_favs")
        .add(favourites.toJson())
        .then((value) => debugPrint("added document for UID $userUID"))
        .catchError((error) =>
            debugPrint("adding document for UID $userUID failed: $error"));
  }

  Future<List<UserFavourites>> getUserFavourites() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await userCollection.doc(userUID).collection("user_favs").get();
    final favourites = snapshot.docs.map((doc) {
      return UserFavourites.fromFireStore(doc);
    }).toList();
    return favourites;
  }

  Future deleteUserData() async {
    return await userCollection.doc(userUID).delete();
  }

  Future<void> deleteFavouriteById({required String id}) async {
  }

  Future<void> deleteAllFavourites() async {
    await userCollection
        .doc(userUID)
        .collection("user_favs")
        .get()
        .then((value) {
      for (DocumentSnapshot ds in value.docs) {
        ds.reference.delete();
      }
    });
  }
}
