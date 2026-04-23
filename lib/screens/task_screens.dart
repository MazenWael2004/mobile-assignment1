import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../Providers/taskProvider.dart';
import './user_profile.dart';
import 'A_E_Screen.dart';
import 'FavoriteTaskScreen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final Color primaryBlue = const Color(0xFF2864A6); 

  @override
  void initState() {
    super.initState();
    // Fetch tasks as soon as the screen loads using Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 26),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteTasksScreen()),
              );
            },
          ),
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
      // Use Consumer to automatically rebuild the UI when tasks change (acts like a consumer in provider-cosumer situation)
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Create one to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                
                // Assignment 2: Explicitly show Task Status
                String statusText = task.isCompleted == 1 ? "Completed" : "Pending";
                Color statusColor = task.isCompleted == 1 ? Colors.green : Colors.orange;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 1), 
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                              color: task.isCompleted == 1 ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                        //new favorite button
                        IconButton(
                          icon: Icon(
                            task.isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
                            color: task.isFavorite == 1 ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            taskProvider.toggleFavorite(task);
                          },
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0), 
                      child: Text(
                        'Due: ${task.dueDate} \nPriority: ${task.priority}\nStatus: $statusText',
                        style: TextStyle(height: 1.4, color: Colors.grey.shade700),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: primaryBlue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: task)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            taskProvider.deleteTask(task.id!);
                          },
                        ),
                        Checkbox(
                          activeColor: primaryBlue,
                          value: task.isCompleted == 1,
                          onChanged: (bool? value) {
                            task.isCompleted = value! ? 1 : 0;
                            taskProvider.updateTask(task);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}