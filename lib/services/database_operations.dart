import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  // Open the database or create it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

Future<Database> _initDatabase() async {
    // Check if we are running on a desktop OS (Linux, Windows, Mac)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Initialize the FFI database factory for desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Find the standard directory for storing databases
    String path = join(await getDatabasesPath(), 'student_tasks.db');

    // Open the database and create the tables
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the Tasks table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
 
  }

  // ==========================================
  // CRUD Operations for Tasks
  // ==========================================

  // CREATE: Add a new task
  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  // READ: Fetch all tasks
  Future<List<Task>> getTasks() async {
    Database db = await instance.database;
    var tasks = await db.query('tasks', orderBy: 'id DESC');
    
    // Convert the List of Maps from SQLite into a List of Task objects
    List<Task> taskList = tasks.isNotEmpty
        ? tasks.map((c) => Task.fromMap(c)).toList()
        : [];
    return taskList;
  }

  // UPDATE: Edit an existing task or mark as complete
  Future<int> updateTask(Task task) async {
    Database db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?', 
      whereArgs: [task.id],
    );
  }

  // DELETE: Remove a task
  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}