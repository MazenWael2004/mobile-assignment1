import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_operations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final Color primaryBlue = const Color(0xFF2864A6);

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('currentUserId');

    if (currentUserId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final result = await db.query('users', where: 'studentID = ?', whereArgs: [currentUserId]);

    if (result.isNotEmpty) {
      final userData = result.first;
      setState(() {
        _nameController.text = userData['fullName'] as String;
        _emailController.text = userData['universityEmail'] as String;
        _idController.text = userData['studentID'].toString();
        String? savedImagePath = userData['profilePictureUrl'] as String?;
        if (savedImagePath != null && savedImagePath.isNotEmpty) {
          _profileImage = File(savedImagePath);
        }
      });
      print("✅ User loaded: ${userData['fullName']} | ID: $currentUserId");
    } else {
      print("⚠️ No user found for ID: $currentUserId");
    }
  }

  Future<void> _saveProfileUpdates() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No user loaded'), backgroundColor: Colors.red),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final rows = await db.update(
      'users',
      {
        'fullName': _nameController.text,
        'profilePictureUrl': _profileImage?.path,
      },
      where: 'studentID = ?',
      whereArgs: [currentUserId],
    );

    print("💾 Rows updated: $rows");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(rows > 0 ? 'Profile Updated Successfully' : 'Update failed')),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null && currentUserId != null) {
      setState(() => _profileImage = File(pickedFile.path));

      final db = await DatabaseHelper.instance.database;
      await db.update(
        'users',
        {'profilePictureUrl': pickedFile.path},
        where: 'studentID = ?',
        whereArgs: [currentUserId],
      );
    }
  }

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
                onTap: () { _pickImage(ImageSource.gallery); Navigator.of(context).pop(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () { _pickImage(ImageSource.camera); Navigator.of(context).pop(); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('currentUserId');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

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
        title: const Text('My Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.person, size: 60, color: Colors.grey.shade600) : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
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
            TextField(controller: _nameController, decoration: _inputDecoration('Full Name')),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: _inputDecoration('University Email'), readOnly: true),
            const SizedBox(height: 16),
            TextField(controller: _idController, decoration: _inputDecoration('Student ID'), readOnly: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfileUpdates, // ✅ actually calls save now
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
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