import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

// Enum to represent the three task filter options
enum TaskFilter { all, pending, completed }

// Main Home Screen of Daily Task Manager
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();

  List<Task> _tasks = [];
  bool _isLoading = true;
  TaskFilter _selectedFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load saved tasks from SharedPreferences
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final loadedTasks = await _storageService.loadTasks();

    setState(() {
      _tasks = loadedTasks;
      _isLoading = false;
    });
  }

  // Filter tasks based on current selection: All, Pending, or Completed
  List<Task> get _filteredTasks {
    switch (_selectedFilter) {
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  // Format today's date for the header: "Monday, 28 Sep 2026"
  String _formatTodayDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Toggle completion status of a task
  Future<void> _toggleTaskCompletion(Task task, bool? newValue) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      isCompleted: newValue ?? !task.isCompleted,
    );

    // Update state immediately for instant UI feedback
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });

    // Persist change to SharedPreferences
    await _storageService.updateTask(updatedTask);
  }

  // Navigate to Add Task Screen
  Future<void> _navigateToAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    // If a new task was added, reload the task list
    if (result == true) {
      _loadTasks();
    }
  }

  // Navigate to Edit Task Screen
  Future<void> _navigateToEditTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );

    // If the task was modified, reload the list
    if (result == true) {
      _loadTasks();
    }
  }

  // Show delete confirmation dialog
  Future<void> _confirmDeleteTask(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this task?'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            // Confirm Delete button
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Remove task from state and storage
      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });

      await _storageService.deleteTask(task.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Get appropriate empty message depending on filter
  String _getEmptyMessage() {
    if (_tasks.isEmpty) {
      return 'No tasks yet';
    }
    switch (_selectedFilter) {
      case TaskFilter.pending:
        return 'No pending tasks';
      case TaskFilter.completed:
        return 'No completed tasks';
      case TaskFilter.all:
        return 'No tasks yet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedTasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              _formatTodayDate(DateTime.now()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips / Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SegmentedButton<TaskFilter>(
              segments: const [
                ButtonSegment<TaskFilter>(
                  value: TaskFilter.all,
                  label: Text('All'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment<TaskFilter>(
                  value: TaskFilter.pending,
                  label: Text('Pending'),
                  icon: Icon(Icons.pending_actions),
                ),
                ButtonSegment<TaskFilter>(
                  value: TaskFilter.completed,
                  label: Text('Completed'),
                  icon: Icon(Icons.task_alt),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<TaskFilter> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),

          // Main Task List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFilter == TaskFilter.completed
                                  ? Icons.task_alt
                                  : Icons.assignment_outlined,
                              size: 64,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getEmptyMessage(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: displayedTasks.length,
                        itemBuilder: (context, index) {
                          final task = displayedTasks[index];
                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            onToggleComplete: (bool? newValue) {
                              _toggleTaskCompletion(task, newValue);
                            },
                            onEdit: () {
                              _navigateToEditTask(task);
                            },
                            onDelete: () {
                              _confirmDeleteTask(task);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      // Floating Action Button to Add New Task
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
