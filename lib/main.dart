import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/task_screens.dart'; 

void main() async {
  // This must be called first when doing async operations in main()
  WidgetsFlutterBinding.ensureInitialized();


  // fixes problem when running in linux
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Now these SQLite commands will work perfectly
  // final dbPath = await getDatabasesPath();
  // await deleteDatabase(join(dbPath, 'student_tasks.db')); 

  runApp(MaterialApp(
    // 3. Set the starting screen to Login
    initialRoute: '/login',
    routes:  {
      "/login": (context) => LoginScreen(),
      "/register": (context) => RegisterScreen(),
      "/tasks": (context) => const TaskListScreen(), // Safely tucked away on its own route
    },
    debugShowCheckedModeBanner: false,
  ));
}