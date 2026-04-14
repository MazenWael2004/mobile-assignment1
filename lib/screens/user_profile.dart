import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Color primaryBlue = const Color(0xFF2864A6);
  
  // Image Picker state
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers for editing profile data
  // When you merge with your friends, populate these with data from SQLite
  final TextEditingController _nameController = TextEditingController(text: "Mustafa Ammar Mahmoud");
  final TextEditingController _emailController = TextEditingController(text: "studentID@stud.fci-cu.edu.eg");
  final TextEditingController _idController = TextEditingController(text: "20201234");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  // Pick Image Function
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Show Bottom Sheet to choose Camera or Gallery
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // The Logout Function
  void _logout() {
    // 1. You would normally clear the user session/login state here
    
    // 2. Navigate to Login and destroy the back-history so they can't hit "Back" to re-enter
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // Input Field Styling (Matching your Signup screen)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: primaryBlue, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile Data Form
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration('University Email'),
              readOnly: true, // Usually, emails aren't editable after signup
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: _inputDecoration('Student ID'),
              readOnly: true, // ID shouldn't change
            ),
            const SizedBox(height: 32),

            // Save Updates Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save updated Name/Photo to SQLite database
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile Updated Successfully')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}