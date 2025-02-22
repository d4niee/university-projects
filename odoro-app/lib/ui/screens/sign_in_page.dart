// ignore_for_file: deprecated_member_use, unnecessary_new

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:odoro/core/services/user_authentication_service.dart';
import 'package:odoro/ui/screens/sign_up_page.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  @override
  State<SignInPage> createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Sign In',
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
                        /// Login to an existing Account
                        SnackBar loginError;
                        context
                            .read<AuthenticationService>()
                            .signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            )
                            .then((value) => {
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
                                  ),
                                  _scaffoldKey.currentState
                                      ?.showSnackBar(loginError)
                                });
                      },
                      child: const Text("Sign In"),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a Member?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      child: Text(
                        ' Register now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                    )
                  ],
                )
              ]),
            ),
          ),
        ));
  }
}
