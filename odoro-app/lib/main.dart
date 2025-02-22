/*
Splash screen package used:
https://pub.dev/packages/flutter_native_splash
 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:odoro/core/providers/selection_controller.dart';
import 'package:odoro/core/routes/route_generator.dart';
import 'package:odoro/core/services/user_authentication_service.dart';
import 'package:odoro/core/providers/settings_controller.dart';
import 'package:odoro/ui/custom_theme/custom_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:odoro/ui/screens/favourites.dart';
import 'package:odoro/ui/screens/home_page.dart';
import 'package:odoro/ui/screens/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'core/services/location_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // root of application: material app that implements theme and router
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          /// Provider for firebase User Authentication
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          StreamProvider(
              create: (context) =>
                  context.read<AuthenticationService>().authStateChanges,
              initialData: null),
          StreamProvider<LatLng>(
            create: (context) => LocationService().locationStream,
            initialData: const LatLng(48.483334, 9.216667),
          ),
          ChangeNotifierProvider(
              create: (context) => SettingsController(),
          ),
          ChangeNotifierProvider(
              create: (context) => SelectionProvider(),
          ),
        ],
        child: Consumer<SettingsController>(
          builder: (context, settings, child) {
            return MaterialApp(
              theme: settings.darkMode ? CustomTheme.darkTheme : CustomTheme.lightTheme,
              title: 'Hike Out',
              initialRoute: RouteGenerator.mainPage,
              onGenerateRoute: RouteGenerator.generateRoute,
            );
          },
        ));
  }
}

/// The Authentication wrapper is used to check if a User is already
/// logged in or not, if the user is logged in wwe show the main page but
/// if not the login page is loaded.
///
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    /// if there is no firebase user -> Login Page
    if (firebaseUser != null) {
      debugPrint("logged in as" + firebaseUser.email.toString());
      return const HomePage(title: 'Hike Out');
    }

    /// If a User is already logged in -> go to main Page
    return SignInPage();
  }
}
