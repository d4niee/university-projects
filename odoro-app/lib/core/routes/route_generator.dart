import 'package:flutter/material.dart';
import 'package:odoro/core/api/weather_api.dart';
import 'package:odoro/core/services/weather_service.dart';
import 'package:odoro/main.dart';
import 'package:odoro/ui/screens/sign_in_page.dart';
import 'package:odoro/ui/screens/sign_up_page.dart';
import '../../ui/screens/overview.dart';
import '../../ui/screens/poi_list.dart';
import '../../ui/screens/settings_page.dart';
import '../../ui/screens/dbtest.dart';
import '../../ui/screens/home_page.dart';
import '../../ui/screens/map_page.dart';
import '../../ui/screens/favourites.dart';
/*
https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments
Route Manager class responsible for all the navigation routes of the app
Defines Route names as static attributes
 */
class RouteGenerator {

  // Route names:
  static const String mainPage = '/';
  static const String mapPage = '/map';
  static const String dbtest = '/db';
  static const String appSettingsPage = '/settings';
  static const String userRoutesPage = '/routes';
  static const String favouritesPage = '/favourites';
  static const String authWrapper = '/authWrapper';
  static const String signInPage = '/signInPage';
  static const String signUpPage = '/signUpPage';

  // Route generator:
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // arguments that are passed when navigation between screens via the passed RouteSettings obj
    final args = settings.arguments;
    // generate the route for each route name and do possible argument validation
    switch(settings.name) {
      case mainPage:
        return MaterialPageRoute(
            builder: (context) => const HomePage(
                title: "Hike Out",
            )
        );
      case appSettingsPage:
        return MaterialPageRoute(
            builder: (context) => const SettingsPage()
        );
      case mapPage:
        return MaterialPageRoute(
            builder: (context) => const MapPage()
        );
      case dbtest:
        return MaterialPageRoute(
            builder: (context) => DBTest()
        );
      case userRoutesPage:
        return MaterialPageRoute(
            builder: (context) => const Overview()
        );
      case favouritesPage:
        return MaterialPageRoute(
            builder: (context) => const Favourites()
        );
      case signInPage:
        return MaterialPageRoute(
          builder: (context) => SignInPage()
        );
      case signUpPage:
        return MaterialPageRoute(
          builder: (context) => SignUpPage()
        );
      case authWrapper:
        return MaterialPageRoute(
          builder: (context) => const AuthenticationWrapper()
        );
      default:
        return _errorRoute();
    }
  }

  // Default error page to redirect to
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Default Error Route"),
        ),
        body: const Center(
          child: Text("Default Error Page"),
        ),
      );
    });
  }
}