import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/route_model.dart';
import '../api/firebase_api.dart';

/*
handles route database interactions
 */
class MapRouteService {
  late final FirebaseApi db;

  MapRouteService() {
    db = FirebaseApi(collectionPath: FirebaseApi.routes);
  }

  /*
  creates a new point of interest to show on the map
  returns the newly created point of interest -> necessary?
   */
  Future<String> createRoute(MapRoute route) async {
    final id = await db.addDocument(route.toJson())
        .then((docRef) {
      print("Generated route id: ${docRef.id}");
      final id = docRef.id;
      return id;
    })
        .onError((error, stacktrace) {
      print(stacktrace);
      print(error);
      return error.toString();
    });
    return id;
  }

  /*
  updates a point of interest on the map
   */
  Future<void> updateRouteByDocumentId(MapRoute route) async {
    await db.updateDocument(route.toJson(), route.polylineId)
        .then((_) => print("PoI updated"))
        .onError((error, stackTrace) => print("Error updating PoI"));
  }

  /*
  returns a list of all points of interest to show on the map
   */
  Future<List<MapRoute>> getAllRoutes() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .getCollection();
    final route = snapshot.docs.map(
            (doc) {
          return MapRoute.fromFireStore(doc);
        }
    ).toList();
    return route;
  }

  /*
  returns a list of routes that fulfill the passed where condition
   */
  Future<List<MapRoute>> getMapRouteWhereKeyValue(String keyName,
      String keyValue) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .getDocumentByKey(keyName, keyValue);
    final routes = snapshot.docs.map(
            (doc) => MapRoute.fromFireStore(doc)
    ).toList();
    return routes;
  }

}