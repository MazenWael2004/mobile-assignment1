import 'package:flutter/material.dart';
import 'package:student_task_management/core/validators/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
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
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                        }
                      },
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
