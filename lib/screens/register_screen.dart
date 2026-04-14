import 'package:flutter/material.dart';
import '../core/validators/auth_validators.dart';
import '../models/user_model.dart';
import '../services/database_operations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController =
      TextEditingController(); // Controller for the name input field
  final _studentIdController =
      TextEditingController(); // Controller for the student ID input field
  final _universityEmailController =
      TextEditingController(); // Controller for the university email input field
  final _genderController =
      TextEditingController(); // Controller for the gender
  final _levelController =
      TextEditingController(); // Controller for the level (optional) input field
  final _confirmPasswordController =
      TextEditingController(); // Controller for the confirm password input field
  final _passwordController =
      TextEditingController(); // Controller for the password input field

  bool _obscurePassword = true; // State variable to toggle password visibility
  bool _obscureConfirmPassword =
      true; // State variable to toggle confirm password visibility
  String? _selectedGender; // Optional field
  int? _selectedLevel; // Optional field

  /// Validates email format and cross-checks email prefix with student ID.
  ///
  /// This method wraps base email validation and then adds relational
  /// validation (`studentId@...` must have studentId as prefix).
  String? _validateEmailWithStudentId(String? email) {
    final emailValidation = AuthValidators.validateFciEmail(email);
    if (emailValidation != null) return emailValidation;

    final studentId = _studentIdController.text.trim();
    if (studentId.isNotEmpty &&
        !AuthValidators.isEmailMatchingStudentId(
          email: email ?? '',
          studentId: studentId,
        )) {
      return 'Student ID and email must match';
    }
    return null;
  }

  void _handleRadioValueChange(String? value) {
  if (value == null) return;

  setState(() {
    _selectedGender = value;
    _genderController.text = value; // optional (for submit)
    print( "Selected Gender: ${_genderController.text}" );
  });
}

  void handleFullNameChange(String value) {
    
    print("Full Name: $value"); // Handle changes to the full name input field
  }

  void handleUniversityEmailChange(String value) {
    print(
      "University Email: $value",
    ); // Handle changes to the university email input field
  }

  void handleStudentIdChange(String value) {
    print("Student ID: $value"); // Handle changes to the student ID input field
  }

 void handleLevelChange(int? value) {
  setState(() {
    _selectedLevel = value;
    _levelController.text = value?.toString() ?? '';
  });

  print("Selected Level: $_selectedLevel");
}
  void _handleSubmit() async{
    if (_formKey.currentState!.validate()) {
      // ✅ all fields valid, proceed with registration logic
      final newUser = User(
        fullName: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        universityEmail: _universityEmailController.text.trim(),
        gender: _genderController.text.trim(),
        profilePictureUrl: null,
        level: _selectedLevel,
        studentID: int.parse(_studentIdController.text.trim()),
      );

      final prefs = await SharedPreferences.getInstance(); // Get shared preferences instance FOR STORING CURRENT USER ID
      await prefs.setInt('currentUserId', newUser.studentID); // Store the current user's student ID in shared preferences

      try {
        final dbHelper = DatabaseHelper.instance;
        final db = await dbHelper.database;

        await db.insert(
          'users',
          userToMap(newUser),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        print("Error occurred while inserting user: $e");
      }

      // Snackbar to show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );

      print("Form is valid. User registered: ${newUser.fullName}, ${newUser.universityEmail}, ${newUser.studentID}");
      // You can also navigate to another screen or reset the form here if needed.
     Navigator.pushNamed(context, '/');

    }

    else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            const SizedBox(height: 20),
            Text(
              "Sign up",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text("Create an account to get started!"),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    validator: AuthValidators
                        .validateName, // Use the name validation method
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Full Name",
                    ),
                    controller:
                        _nameController, // Connect the controller to the TextField
                    onChanged: (value) => handleFullNameChange(
                      value,
                    ), // Call the handler function when the text changes
                  ),
                  const SizedBox(height: 10),
                  Text("Gender"),
                  Column(
                    children: [
                      RadioListTile(
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: _handleRadioValueChange,
                        title: Text("Male"),
                      ),
                      RadioListTile(
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: _handleRadioValueChange,
                        title: Text("Female"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    validator:
                        _validateEmailWithStudentId, // Use the combined email validation method
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "University Email",
                    ),
                    controller:
                        _universityEmailController, // Connect the controller to the TextField
                    onChanged: (value) => handleUniversityEmailChange(
                      value,
                    ), // Call the handler function when the text changes
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    validator: AuthValidators
                        .validateStudentId, // Use the student ID validation method
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Student ID",
                    ),
                    controller:
                        _studentIdController, // Connect the controller to the TextField
                    onChanged: (value) => handleStudentIdChange(
                      value,
                    ), // Call the handler function when the text changes
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedLevel,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Level 1')),
                      DropdownMenuItem(value: 2, child: Text('Level 2')),
                      DropdownMenuItem(value: 3, child: Text('Level 3')),
                      DropdownMenuItem(value: 4, child: Text('Level 4')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedLevel = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Level (optional)',
                      prefixIcon: Icon(Icons.stairs_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        // 👈 add this
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: AuthValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password *',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      return AuthValidators.validateConfirmPassword(
                        confirmPassword: value,
                        password: _passwordController.text,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _handleSubmit,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 39, 103, 176),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      child: Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
