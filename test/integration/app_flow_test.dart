import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promodo_study/main.dart';
import 'package:promodo_study/core/service_locator.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Timer Flow Integration Tests', () {
    setUp(() async {
      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.reset();
      }
      await setupDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('Complete timer cycle: select theme, start session, complete cycle',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final themeButton = find.text('Chọn Theme');
      if (themeButton.evaluate().isNotEmpty) {
        await tester.tap(themeButton);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }

      final startButton = find.text('Bắt đầu');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      final oneCycleButton = find.text('1');
      expect(oneCycleButton, findsOneWidget);

      await tester.tap(oneCycleButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Tạm dừng'), findsOneWidget);
      expect(find.text('HỌC'), findsOneWidget);

      await tester.tap(find.text('Tạm dừng'));
      await tester.pumpAndSettle();

      expect(find.text('Tiếp tục'), findsOneWidget);

      await tester.tap(find.text('Tiếp tục'));
      await tester.pumpAndSettle();

      expect(find.text('Tạm dừng'), findsOneWidget);
    });

    testWidgets('Reset timer session', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final startButton = find.text('Bắt đầu');
      if (startButton.evaluate().isNotEmpty) {
        await tester.tap(startButton);
        await tester.pumpAndSettle();

        await tester.tap(find.text('1'));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        expect(find.text('Bắt đầu'), findsOneWidget);
      }
    });
  });

  group('Task Management Integration Tests', () {
    setUp(() async {
      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.reset();
      }
      await setupDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('Add and complete task', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final tasksTab = find.byIcon(Icons.checklist);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();

      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final titleField = find.byType(TextField);
      await tester.enterText(titleField, 'Test Task Integration');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      expect(find.text('Test Task Integration'), findsOneWidget);

      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

    });

    testWidgets('Delete task', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Task to Delete');
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();

      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle();

        final confirmButton = find.text('Xóa');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }
      }
    });
  });

  group('Statistics Integration Tests', () {
    setUp(() async {
      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.reset();
      }
      await setupDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('View statistics screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final statsTab = find.byIcon(Icons.bar_chart);
      await tester.tap(statsTab);
      await tester.pumpAndSettle();

      expect(find.text('Thống kê học tập'), findsAny);
      
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Switch between daily, weekly, and monthly stats',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      final weeklyButton = find.text('Tuần');
      if (weeklyButton.evaluate().isNotEmpty) {
        await tester.tap(weeklyButton);
        await tester.pumpAndSettle();
      }

      final monthlyButton = find.text('Tháng');
      if (monthlyButton.evaluate().isNotEmpty) {
        await tester.tap(monthlyButton);
        await tester.pumpAndSettle();
      }

      final dailyButton = find.text('Ngày');
      if (dailyButton.evaluate().isNotEmpty) {
        await tester.tap(dailyButton);
        await tester.pumpAndSettle();
      }
    });
  });

  group('Navigation Integration Tests', () {
    setUp(() async {
      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.reset();
      }
      await setupDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('Navigate through all main screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer), findsOneWidget);

      await tester.tap(find.byIcon(Icons.checklist));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      final goalsTab = find.byIcon(Icons.flag);
      if (goalsTab.evaluate().isNotEmpty) {
        await tester.tap(goalsTab);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byIcon(Icons.timer));
      await tester.pumpAndSettle();
    });
  });
}
