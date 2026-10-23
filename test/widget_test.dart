import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_task_manager/main.dart';

void main() {
  testWidgets('App renders Home Screen with title and empty state', (WidgetTester tester) async {
    // Set initial mock values for SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Build the app
    await tester.pumpWidget(const DailyTaskManagerApp());
    await tester.pumpAndSettle();

    // Verify app title is displayed
    expect(find.text('Daily Task Manager'), findsOneWidget);

    // Verify empty state message is shown
    expect(find.text('No tasks yet'), findsOneWidget);

    // Verify filter buttons are displayed
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });
}
