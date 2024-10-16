// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/api_services/task_service.dart';
import 'package:task_manager/model/tasks.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask; // Optional parameter to edit an existing task

  const AddTaskScreen({super.key, this.existingTask}); // Constructor

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _isLoading = false; // To show loading indicator during API call

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _nameController.text = widget.existingTask!.name;
      _descriptionController.text = widget.existingTask!.description;
      _dueDate = widget.existingTask!.dueDate;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAddOrUpdateTask() async {
  if (_nameController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _dueDate == null) {
    _showSnackBar('Please fill all fields');
    return;
  }

  if (_dueDate!.isBefore(DateTime.now())) {
    _showSnackBar('Due date cannot be in the past');
    return;
  }

  // New validation to check for duplicates
    final existingTasks = await TaskService.fetchTasks(); // Fetch existing tasks
    final taskExists = existingTasks.any((task) =>
        task.name == _nameController.text && task.dueDate == _dueDate);

    if (taskExists) {
        _showSnackBar('A task with this name and due date already exists.');
        return;
    }

  setState(() {
    _isLoading = true;
  });

  try {
    if (widget.existingTask == null) {
      // Creating a new task
      final newTask = Task(
        id: UniqueKey().toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        dueDate: _dueDate!,
      );
      await TaskService.createTask(newTask);
      Navigator.pop(context, newTask); 
    } else {
      // Updating the existing task
      final updatedTask = widget.existingTask!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        dueDate: _dueDate!,
      );
      await TaskService.updateTask(updatedTask);
      Navigator.pop(context, updatedTask); // Navigate back with the updated task
    }
  } catch (error) {
    _showSnackBar('Failed to save task. Please try again. Error: $error');
  } finally {
    setState(() {
      _isLoading = false; // Hide loading
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.existingTask == null ? 'Add Task' : 'Edit Task'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/add_tasks.jpg',
                        height: 270,
                        width: 270,
                      ),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Task Name',
                        icon: Icons.task,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16.0),
                      _buildDueDatePicker(),
                      const SizedBox(height: 20.0),
                      _buildAddTaskButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Widget _buildDueDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text(_dueDate == null
            ? 'Select Due Date'
            : 'Due Date: ${DateFormat.yMMMd().format(_dueDate!)}'),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _dueDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            setState(() {
              _dueDate = picked;
            });
          }
        },
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return ElevatedButton(
      onPressed: _handleAddOrUpdateTask,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(widget.existingTask == null ? 'Add Task' : 'Update Task'),
    );
  }
}
