import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes:  {
        "/": (context) =>  LoginScreen(),
         "/register": (context) => RegisterScreen()
      },
    debugShowCheckedModeBanner: false,
  ));
}

