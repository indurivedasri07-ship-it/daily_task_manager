import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

// Service to manage task persistence using SharedPreferences
class StorageService {
  static const String _tasksKey = 'daily_tasks_data';

  // Load all tasks from SharedPreferences
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_tasksKey);

      if (tasksJson == null || tasksJson.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(tasksJson);
      return decodedList
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  // Save the full list of tasks to SharedPreferences
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> taskListMap =
          tasks.map((task) => task.toJson()).toList();
      final String encodedJson = jsonEncode(taskListMap);
      return await prefs.setString(_tasksKey, encodedJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
      return false;
    }
  }

  // Add a single task to storage
  Future<bool> addTask(Task task) async {
    final tasks = await loadTasks();
    tasks.insert(0, task); // Add newest task at the top
    return await saveTasks(tasks);
  }

  // Update an existing task in storage
  Future<bool> updateTask(Task updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      return await saveTasks(tasks);
    }
    return false;
  }

  // Delete a task from storage by ID
  Future<bool> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == taskId);
    return await saveTasks(tasks);
  }
}
