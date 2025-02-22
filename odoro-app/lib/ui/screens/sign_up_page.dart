// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/services/user_authentication_service.dart';
import 'package:odoro/ui/screens/sign_up_page.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String success = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                Image.asset(
                  'assets/logo_final.png',
                  height: 180,
                  width: 180,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Create a new Account',
                  style: TextStyle(fontSize: 25, color: Colors.green),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(hintText: 'E-Mail'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(hintText: 'Username'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: const InputDecoration(hintText: 'Password'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ButtonTheme(
                    buttonColor: Colors.green,
                    child: RaisedButton(
                      disabledElevation: 4.0,
                      onPressed: () {
                        SnackBar loginError;
                        context
                            .read<AuthenticationService>()
                            .signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                username: usernameController.text.trim())
                            .then((value) {
                          success = value.toLowerCase().toString();
                          debugPrint(success);
                          loginError = SnackBar(
                            content: Text(
                              value.toString(),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            elevation: 10,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(5),
                          );
                          _scaffoldKey.currentState?.showSnackBar(loginError);
                           if (success == "success") {
                          debugPrint("successfully logged in");
                          Navigator.pop(context);
                        }
                        });
                      },
                      child: const Text("Create Account"),
                    )),
                const SizedBox(
                  height: 20,
                ),
              ]),
            ),
          ),
        ));
  }
}
