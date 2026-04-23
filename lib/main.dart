import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';

import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/task_screens.dart'; 
import './Providers/taskProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  //run after every database schema change
  // final dbPath = await getDatabasesPath();
  // await deleteDatabase(join(dbPath, 'student_tasks.db')); 
runApp(
    // 3. Wrap your MaterialApp with ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        initialRoute: '/login',
        routes:  {
          "/login": (context) => const LoginScreen(),
          "/register": (context) => const RegisterScreen(),
          "/tasks": (context) => const TaskListScreen(), 
        },
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}