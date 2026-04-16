import 'package:flutter/material.dart';
import '../core/validators/auth_validators.dart';
import '../models/user_model.dart';
import '../services/database_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


void _attemptLogin()async {
  if (_formKey.currentState!.validate()) {
    // If the form is valid, display a snackbar. In the real world,
    // you'd often call a server or save the information in a database.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data')),
    );
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'universityEmail = ? AND password = ?',
      whereArgs: [_emailController.text, _passwordController.text],
    );

    if(result.isNotEmpty){
      // Login successful, save user ID in shared preferences
      final user = userFromMap(result.first);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user.studentID);

      // Navigate to the main task screen
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // Login failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fix the errors in red before submitting.')),
    );
  }
}
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign in to your Account",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 15),
            Text("Enter your email and password to log in"),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Email",
                    ),
                    validator: AuthValidators.validateFciEmail,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: "Password",
                      
                    ),
                    validator: AuthValidators.validatePassword,
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color.fromARGB(255, 39, 103, 176),
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          letterSpacing: 3,
                          fontWeight: FontWeight(700),
                          fontSize: 20,

                        ),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(onPressed: () {
                  Navigator.pushNamed(context, "/register");
                }, child: Text("Sign up"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
