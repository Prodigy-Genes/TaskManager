// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_constructors, use_super_parameters, use_build_context_synchronously

import 'dart:math'; // Import for generating random numbers
import 'package:flutter/material.dart';
import 'package:task_manager/api_services/task_service.dart';
import 'package:task_manager/screens/addtask_screen.dart';
import 'package:task_manager/screens/completed_tasks_screen.dart';
import '../model/tasks.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(Task) onUpdate; 
  final Function(Task) onDelete; 
  final Function(Task) onComplete; 

  const TaskCard({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Color _getRandomCardColor() {
    final List<Color> cardColors = [
      const Color.fromRGBO(253, 253, 250, 1),
      Colors.orange,
      Colors.white,
      Colors.yellow,
      Colors.blue,
    ];
    return cardColors[Random().nextInt(cardColors.length)];
  }

  Future<void> _toggleCompletion() async {
    setState(() {
      widget.task.isCompleted = true;
    });

    // Pass the updated task back to the parent
    widget.onComplete(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getRandomCardColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: cardColor,
      child: ListTile(
        title: Text(widget.task.name),
        subtitle: Text('${widget.task.description}\nDue: ${widget.task.dueDate}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                widget.task.isCompleted ? Icons.check_circle : Icons.circle,
                color: widget.task.isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: _toggleCompletion, // Call toggle method
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showTaskOptions(context);
              },
            ),
          ],
        ),
        onTap: () => widget.onUpdate(widget.task), // Pass task to update callback
      ),
    );
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onUpdate(widget.task); // Pass task to update callback
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Task'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete(widget.task); // Pass task to delete callback
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


class TasksScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onUpdateTask; // Accepting onUpdateTask as a parameter
  final Function(Task) onCompleteTask; // Accepting onCompleteTask as a parameter
  final Function(Task) onDeleteTask; // Accepting onDeleteTask as a parameter

  const TasksScreen({
    Key? key,
    required this.onUpdateTask,
    required this.onCompleteTask,
    required this.onDeleteTask, required this.tasks,
  }) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = []; // Local state to store tasks
  List<Task> completedTasks = []; // Store completed tasks
  bool isLoading = true; // State variable to track loading

  @override
  void initState() {
    super.initState();
    _fetchTasks(); // Fetch tasks when the widget is initialized
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await TaskService.fetchTasks(); // Fetch tasks from API
      setState(() {
        tasks = fetchedTasks; // Update tasks
        isLoading = false; // Set loading to false after fetching
      });
    } catch (error) {
      print('Error fetching tasks: $error');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  void _handleDeleteTask(Task task) async {
  try {
    await TaskService.deleteTask(task.id); // Call the delete API

    // Re-fetch tasks after deletion
    await _fetchTasks();
  } catch (error) {
    print('Error deleting task: $error');
    // Handle any errors (e.g., show a Snackbar or Dialog)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete task')),
    );
  }
}


   void _handleCompleteTask(Task task) async {
    // Mark task as completed and move to completedTasks list
    setState(() {
      task.isCompleted = true; // Update the completion status locally
      tasks.remove(task); // Remove from current tasks
      completedTasks.add(task); // Add to completed tasks
    });

    // Navigate to the completed tasks screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedTasksScreen(completedTasks: completedTasks),
      ),
    );
  }

void _handleUpdateTask(Task updatedTask) async {
  // Navigate to the task editing screen (assuming you have a screen named AddTask)
  final editedTask = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddTaskScreen(
        existingTask: updatedTask, // Pass the current task to be edited
      ),
    ),
  );

  // Update task with the returned edited task
  if (editedTask != null) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == editedTask.id);
      if (index != -1) {
        tasks[index] = editedTask; // Update the task in the list
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator()); // Show loading spinner
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onUpdate: _handleUpdateTask, // Pass the update handler
          onComplete: _handleCompleteTask, // Pass the complete handler
          onDelete: _handleDeleteTask, // Pass the delete handler
        );
      },
    );
  }
}


