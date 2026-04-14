import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/database_operations.dart';
import 'package:intl/intl.dart'; 

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // If null, we are adding. If not null, we are editing.

  const AddEditTaskScreen({super.key, this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryBlue = const Color(0xFF2864A6);

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  
  String _priority = 'Medium'; // Default priority
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if we are editing, or empty if adding
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDateController = TextEditingController(text: widget.task?.dueDate ?? '');
    
    if (widget.task != null) {
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // Native Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format the date to a readable string
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveTask() async {
    // This triggers the validators in the TextFormFields
    if (_formKey.currentState!.validate()) {
      Task taskToSave = Task(
        id: widget.task?.id, // Keep the same ID if editing
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDateController.text.trim(),
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? 0,
      );

      if (widget.task == null) {
        await DatabaseHelper.instance.insertTask(taskToSave);
      } else {
        await DatabaseHelper.instance.updateTask(taskToSave);
      }

      // Go back to the previous screen and pass 'true' to signal a refresh is needed
      if (mounted) Navigator.pop(context, true);
    }
  }

  // A helper method to keep our UI code clean and matching the signup screen style
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
        title: Text(
          widget.task == null ? 'Add New Task' : 'Edit Task',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Task Title *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Task Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Due Date Field (Read-only, opens DatePicker)
              TextFormField(
                controller: _dueDateController,
                readOnly: true,
                decoration: _inputDecoration('Due Date *').copyWith(
                  suffixIcon: Icon(Icons.calendar_today, color: primaryBlue),
                ),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: _inputDecoration('Priority Level'),
                items: _priorities.map((String priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  widget.task == null ? 'CREATE TASK' : 'UPDATE TASK',
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}