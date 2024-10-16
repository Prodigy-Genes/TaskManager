// services/task_service.dart

// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/tasks.dart';

class TaskService {
  static const String baseUrl = 'https://todo-liard-phi.vercel.app/api/todo';

  // Mark a task as complete or incomplete
  static Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/$taskId'), // Use baseUrl
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isCompleted': isCompleted}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task completion');
    }
  }

  // Create a new task
  static Future<Task?> createTask(Task task) async {
  try {
    print('Creating task with data: ${jsonEncode(task.toJson())}');

    final response = await http.post(
      Uri.parse('https://todo-liard-phi.vercel.app/api/todo'), 
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()), 
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final taskData = jsonDecode(response.body);
      return Task.fromJson(taskData); // Ensure this method matches your API response structure
    } else {
      print('Failed to create task: ${response.statusCode} ${response.reasonPhrase}');
      throw Exception('Failed to create task: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error creating task: $error');
    throw Exception('Error creating task: $error');
  }
}



  // Update an existing task
  // Update an existing task
static Future<Task?> updateTask(Task task) async {
  try {
    // Full URL to the task update API, using task.id to construct the endpoint
    final url = 'https://todo-liard-phi.vercel.app/api/todo/${task.id}';

    final response = await http.put(
      Uri.parse(url), // Corrected URL endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()), // Convert task data to JSON
    );

    // Check the status code for a successful update
    if (response.statusCode == 200) {
      // Parse and return the updated task
      return Task.fromJson(jsonDecode(response.body));
    } else {
      // If not successful, throw an exception with the status code and reason
      throw Exception('Failed to update task: ${response.reasonPhrase}');
    }
  } catch (error) {
    // Catch and rethrow errors for logging or further handling
    throw Exception('Failed to update task: $error');
  }
}


  // Delete a task
  static Future<bool> deleteTask(String id) async {
  try {
    print('Deleting task with ID: $id'); // Debug: Print the task ID

    // Perform the DELETE request
    final response = await http.delete(Uri.parse('https://todo-liard-phi.vercel.app/api/todo/$id'));

    if (response.statusCode == 200) {
      return true; // Task deleted successfully
    } else {
      // Log the failure and the response body
      print('Failed to delete task: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false; // Task deletion failed
    }
  } catch (e) {
    print('Error deleting task: $e');
    return false; // Catch any errors
  }
}


  // Mark a task as complete
  static Future<Task?> completeTask(Task task) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/${task.id}'), // Use baseUrl
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isCompleted': !task.isCompleted}), // Toggle completion status
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      print('Failed to complete task: ${response.statusCode}');
      return null;
    }
  }

  // Fetch all tasks
  static Future<List<Task>> fetchTasks() async {
    try {
      print('Fetching tasks from API...');
      final response = await http.get(Uri.parse(baseUrl));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['data'] is List) {
          return (data['data'] as List).map((taskJson) {
            String name = taskJson['title'] ?? 'Unnamed Task';
            String description = taskJson['description'] ?? 'No Description';
            DateTime dueDate = taskJson['dueDate'] != null
                ? DateTime.tryParse(taskJson['dueDate']) ?? DateTime.now()
                : DateTime.now();

            return Task(
              id: taskJson['id'].toString(),
              name: name,
              description: description,
              dueDate: dueDate,
              isCompleted: taskJson['isCompleted'] ?? false,
            );
          }).toList();
        } else {
          print('Unexpected data format: ${data['data']}');
          return [];
        }
      } else {
        // Handle different response codes
        switch (response.statusCode) {
          case 400:
            throw Exception('Bad Request: The server could not understand the request.');
          case 401:
            throw Exception('Unauthorized: Access is denied due to invalid credentials.');
          case 403:
            throw Exception('Forbidden: You do not have permission to access this resource.');
          case 404:
            throw Exception('Not Found: The requested resource could not be found.');
          case 500:
            throw Exception('Internal Server Error: The server encountered an unexpected condition.');
          default:
            throw Exception('Failed to load tasks: ${response.statusCode}');
        }
      }
    } on FormatException catch (e) {
      print('Format error: $e');
      throw Exception('Invalid response format: $e');
    } on http.ClientException catch (e) {
      print('HTTP client error: $e');
      throw Exception('Network error: $e');
    } catch (e) {
      print('Error fetching tasks: $e');
      throw Exception('Error fetching tasks: $e');
    }
  }
}
