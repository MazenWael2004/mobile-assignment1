import 'package:flutter/material.dart';
import '../../services/database_operations.dart';
import '../../models/task_model.dart';
import "A_E_Screen.dart";
import "../screens/user_profile.dart";
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> taskList = [];
  bool isLoading = true;

  final Color primaryBlue = const Color(0xFF2864A6); 

  @override
  void initState() {
    super.initState();
    _refreshTaskList();
  }

  Future<void> _refreshTaskList() async {
    List<Task> tasks = await DatabaseHelper.instance.getTasks();
    setState(() {
      taskList = tasks;
      isLoading = false;
    });
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
          'Task Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ), // <-- The Text widget perfectly closes right here
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryBlue)) 
          : taskList.isEmpty
              ? const Center(
                  child: Text(
                    'No tasks yet.Create one to get started',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      final task = taskList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // Matching the outlined border style of the sign-up fields
                          border: Border.all(color: Colors.grey.shade400, width: 1), 
                          borderRadius: BorderRadius.circular(8.0),
                        ),
child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted == 1 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                              color: task.isCompleted == 1 ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Padding(
            
                            padding: const EdgeInsets.only(top: 4.0), 
                            child: Text(
                              'Due: ${task.dueDate}\nPriority: ${task.priority}',
                              style: TextStyle(
                                height: 1.4,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: primaryBlue),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditTaskScreen(task: task),
                                    ),
                                  );
                                  if (result == true) {
                                    _refreshTaskList();
                                  }
                                },
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  await DatabaseHelper.instance.deleteTask(task.id!);
                                  _refreshTaskList();
                                },
                              ),
                              // Complete Checkbox
                              Checkbox(
                                activeColor: primaryBlue,
                                value: task.isCompleted == 1,
                                onChanged: (bool? value) async {
                                  task.isCompleted = value! ? 1 : 0;
                                  await DatabaseHelper.instance.updateTask(task);
                                  _refreshTaskList();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      // Add new task 
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditTaskScreen(),
                ),
              );
              if (result == true) {
                _refreshTaskList();
              }
            },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}