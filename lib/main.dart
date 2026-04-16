import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import 'screens/task_screens.dart';
import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';
// 1. Point to the file we just created
import './screens/task_screens.dart'; 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



void main() async {
    WidgetsFlutterBinding.ensureInitialized();


  final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'student_tasks.db'));

  runApp(MaterialApp(
    initialRoute: '/login',
    routes:  {
        // 2. TEMPORARILY bypass login by making TaskListScreen the default '/' route
        "/": (context) => const TaskListScreen(), 
        
        // We will keep your friends' screens mapped here so they aren't lost
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen()
      },
    debugShowCheckedModeBanner: false,
  ));
}