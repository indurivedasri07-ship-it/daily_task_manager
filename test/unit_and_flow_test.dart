import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_task_manager/models/task.dart';
import 'package:daily_task_manager/services/storage_service.dart';
import 'package:daily_task_manager/screens/home_screen.dart';

void main() {
  group('Task Model & StorageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Task converts to JSON and back from JSON correctly', () {
      final now = DateTime(2026, 9, 28, 12, 0, 0);
      final task = Task(
        id: '123',
        title: 'Complete Flutter Assignment',
        description: 'Finish the Daily Task Manager',
        date: now,
        isCompleted: false,
      );

      final json = task.toJson();
      expect(json['id'], '123');
      expect(json['title'], 'Complete Flutter Assignment');
      expect(json['description'], 'Finish the Daily Task Manager');
      expect(json['isCompleted'], false);

      final reconstructed = Task.fromJson(json);
      expect(reconstructed.id, task.id);
      expect(reconstructed.title, task.title);
      expect(reconstructed.description, task.description);
      expect(reconstructed.date, task.date);
      expect(reconstructed.isCompleted, task.isCompleted);
    });

    test('StorageService saves, loads, updates, and deletes tasks', () async {
      final storage = StorageService();

      // Initially empty
      final initialTasks = await storage.loadTasks();
      expect(initialTasks, isEmpty);

      // Add a task
      final task1 = Task(
        id: '1',
        title: 'Task 1',
        description: 'First Description',
        date: DateTime(2026, 9, 28),
      );
      await storage.addTask(task1);

      var tasks = await storage.loadTasks();
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Task 1');

      // Update task
      task1.isCompleted = true;
      await storage.updateTask(task1);

      tasks = await storage.loadTasks();
      expect(tasks.first.isCompleted, true);

      // Delete task
      await storage.deleteTask('1');
      tasks = await storage.loadTasks();
      expect(tasks, isEmpty);
    });
  });

  group('HomeScreen Interactive Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Full Task Flow: Add, Toggle, Filter, and Delete', (WidgetTester tester) async {
      final storage = StorageService();
      // Pre-populate with two tasks: one pending, one completed
      await storage.addTask(
        Task(
          id: 'task-done',
          title: 'Completed Task',
          description: 'This is completed',
          date: DateTime(2026, 9, 28),
          isCompleted: true,
        ),
      );
      await storage.addTask(
        Task(
          id: 'task-pending',
          title: 'Pending Task',
          description: 'This is pending',
          date: DateTime(2026, 9, 28),
          isCompleted: false,
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      // Verify both tasks are visible in "All" view
      expect(find.text('Pending Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);

      // Switch filter to "Pending"
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();
      expect(find.text('Pending Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsNothing);

      // Switch filter to "Completed"
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Pending Task'), findsNothing);
      expect(find.text('Completed Task'), findsOneWidget);

      // Switch back to "All"
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Test Delete Dialog: Tap delete icon on Pending Task
      final deleteIcons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteIcons.first);
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Delete this task?'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this task?'), findsOneWidget);

      // Tap Delete in dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      // One task should remain
      expect(find.byType(Card), findsNWidgets(1));
    });
  });
}
