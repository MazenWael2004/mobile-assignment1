import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/taskProvider.dart';

class FavoriteTasksScreen extends StatelessWidget {
  const FavoriteTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF2864A6);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Favorite Tasks',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Grab only the favorited tasks using the getter we made earlier
          final favoriteTasks = taskProvider.favoriteTasks;

          if (favoriteTasks.isEmpty) {
            return const Center(
              child: Text(
                'No favorite tasks yet.\nTap the heart icon on a task to add it here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.builder(
              itemCount: favoriteTasks.length,
              itemBuilder: (context, index) {
                final task = favoriteTasks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red.shade200, width: 1.5), // Subtle red border for favorites
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Due: ${task.dueDate} \nPriority: ${task.priority}',
                        style: TextStyle(height: 1.4, color: Colors.grey.shade700),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                      tooltip: 'Remove from favorites',
                      onPressed: () {
                        // This removes it from the database and instantly updates the UI
                        taskProvider.toggleFavorite(task);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}