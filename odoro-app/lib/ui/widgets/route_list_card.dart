import 'package:flutter/material.dart';
import 'package:odoro/core/providers/selection_controller.dart';
import 'package:provider/provider.dart';
import '../../core/routes/route_generator.dart';
import '../../models/route_model.dart';
import '../custom_theme/custom_theme.dart';

class RouteCard extends StatelessWidget {

  final MapRoute route;

  RouteCard({required this.route, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectionProvider = Provider.of<SelectionProvider>(context);
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              // TODO: add to selection and confirm in snackbar, switch to map
              selectionProvider.addToPolylines(route);
              print("selected route $route");
              // TODO open map with a navigator call
              Navigator.pushNamed(context, RouteGenerator.mapPage);
            },
            leading: CircleAvatar(
                backgroundColor: MyColorTheme.primaryGreyShade,
                child: Image.asset("assets/route_orange.png")
            ),
            title: Text("Name: ${route.routeName}"),
            subtitle: Text("Distance: ${route.routeDistance}"),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(route.routeDescription)
          ),
        ],
      ),
    );
  }

}