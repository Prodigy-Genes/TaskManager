// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:task_manager/api_services/task_service.dart';
import 'package:task_manager/screens/addtask_screen.dart';
import 'package:task_manager/screens/completed_tasks_screen.dart';
import 'package:task_manager/widgets/tasks.dart';
import 'package:task_manager/widgets/tasks_counter.dart';
//import 'package:task_manager/widgets/tasks_summary.dart';
import '../model/tasks.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Fetch tasks from API
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    List<Task> fetchedTasks = await TaskService.fetchTasks();

    setState(() {
      tasks = fetchedTasks;
      _isLoading = false;
    });
  }

  // Function to handle both adding and editing a task
  Future<void> _handleTask(Task? task) async {
    final Task? newOrUpdatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(existingTask: task),
      ),
    );

    if (newOrUpdatedTask != null) {
      setState(() {
        if (task == null) {
          // Adding a new task
          tasks.add(newOrUpdatedTask);
        } else {
          // Editing an existing task
          final index = tasks.indexWhere((t) => t.id == newOrUpdatedTask.id);
          if (index != -1) {
            tasks[index] = newOrUpdatedTask;
          }
        }
      });
    }
  }

  // Function to delete a task by making a DELETE request
  Future<void> deleteTask(Task task) async {
    bool success = await TaskService.deleteTask(task.id);
    if (success) {
      setState(() {
        tasks.remove(task);
      });
      await _loadTasks(); // Fetch tasks again after deletion
    } else {
      // Handle error
      print('Failed to delete task');
    }
  }

  // Function to mark a task as complete by updating the isCompleted field
  Future<void> _completeTask(Task completedTask) async {
    Task? task = await TaskService.completeTask(completedTask);
    if (task != null) {
      setState(() {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          // Remove the task from the main list
          tasks.removeAt(index);
        }
      });
      // Optionally, you might want to navigate or update UI here
      await _loadTasks(); // Fetch tasks again after completion
    } else {
      // Handle error
      print('Failed to mark task as complete');
    }
  }

  int _getInProgressTaskCount() {
    final count = tasks.where((task) => !task.isCompleted).length;
    print("In-progress task count: $count");
    return count;
  }

  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompletedTasksScreen(completedTasks: completedTasks),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_tasks.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No tasks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You have no tasks at the moment.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TaskSummary(tasks: tasks),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'In Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TaskCounter(taskCount: _getInProgressTaskCount()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TasksScreen(
                        tasks: tasks,
                        onUpdateTask: (task) => _handleTask(task),
                        onCompleteTask: (task) async {
                          await _completeTask(task);
                          _loadTasks();
                        },
                        onDeleteTask: (task) async {
                          await deleteTask(task);
                          _loadTasks();
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _handleTask(null);
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
