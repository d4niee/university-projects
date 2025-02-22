/*
shows all saved routes of a user
analog zu flutter übung
 */
import 'package:flutter/material.dart';
import 'package:odoro/core/services/route_service.dart';
import 'package:odoro/ui/widgets/route_list_card.dart';

import '../../core/services/pointofinterest_service.dart';
import '../../models/pointofinterest_model.dart';
import '../../models/route_model.dart';
import 'location_list_card.dart';

class RoutesList extends StatefulWidget {
  const RoutesList({Key? key}) : super(key: key);

  static const title = "Browse Routes";

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {

  final MapRouteService mapRouteService = MapRouteService();
  late List<MapRoute> routes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<MapRoute>>(
          future: mapRouteService.getAllRoutes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final route = snapshot.data![index];
                  return RouteCard(route: route);
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search_outlined),
        onPressed: () {},
      ),
    );
  }
}