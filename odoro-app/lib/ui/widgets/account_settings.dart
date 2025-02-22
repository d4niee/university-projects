import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/services/user_authentication_service.dart';
import 'package:odoro/main.dart';
import 'package:odoro/ui/screens/sign_in_page.dart';
import 'package:provider/provider.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class AccountSettings extends StatefulWidget {
  const AccountSettings({Key? key}) : super(key: key);
  static const String title = "Account Settings";
  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

String getUserEmail(User? user) {
  if (user == null) {
    return "Nothing to see here :(";
  }
  return user.email.toString();
}

String getDisplayName(User? user) {
  if (user == null) {
    return "Nothing to see here :(";
  }
  return user.displayName.toString();
}

class _AccountSettingsState extends State<AccountSettings> {
  void _deleteAccount(BuildContext context, User user) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text("Delete My Account"),
            content: const Text(
                "Are you sure you want to delete your account permanently? This operation cannot be undone!"),
            actions: [
              // YES Button
              TextButton(
                  onPressed: () {
                    context.read<AuthenticationService>().deleteAccount(user);
                    Navigator.pop(context);
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        //change Column to Listview if needs to be scrollable
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Account"),
                subtitle: Text("Username: " + getDisplayName(firebaseUser) + "\nE-Mail: " + getUserEmail(firebaseUser)),
              ),
            ),
            RaisedButton(
              color: const Color.fromARGB(255, 139, 139, 139),
              textColor: Colors.white,
              child: const Text("Reset Password"),
              onPressed: () {
                SnackBar passwordReset;
                context
                    .read<AuthenticationService>()
                    .resetPassword(email: getUserEmail(firebaseUser))
                    .then((value) => {
                          passwordReset = SnackBar(
                            content: Text(
                              value.toString(),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                            backgroundColor: Colors.grey,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(5),
                          ),
                          _scaffoldKey.currentState!.showSnackBar(passwordReset)
                        });
                //Navigator.push(context,
                //    MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
            RaisedButton(
              color: Colors.grey,
              textColor: Colors.white,
              child: const Text("Logout"),
              onPressed: () {
                context.read<AuthenticationService>().signOut();
                Navigator.pop(context);
                SignInPage();
                //Navigator.push(context,
                //    MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
            RaisedButton(
              color: Colors.red.shade400,
              textColor: Colors.white,
              child: const Text("Delete My Account"),
              onPressed: () {
                if (firebaseUser != null) {
                  _deleteAccount(context, firebaseUser);
                }
                //Navigator.push(context,
                //    MaterialPageRoute(builder: (context) => SignInPage()));
              },
            ),
            const Card(
              child: ListTile(
                title: Text("Other Settings:"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
