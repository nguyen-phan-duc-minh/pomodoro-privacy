import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/goal_provider.dart';
import 'package:promodo_study/models/goal.dart';
import 'package:promodo_study/models/study_statistics.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IGoalRepository])
import 'goal_provider_test.mocks.dart';

void main() {
  group('GoalProvider Tests', () {
    late GoalProvider provider;
    late MockIGoalRepository mockRepository;

    setUp(() {
      mockRepository = MockIGoalRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadGoals()).thenAnswer((_) async => []);
      when(mockRepository.saveGoals(any)).thenAnswer((_) async {});
      
      provider = GoalProvider(mockRepository);
    });

    test('Initialize loads goals from repository', () async {
      final goalsData = [
        {
          'id': '1',
          'title': 'Study 60 minutes',
          'type': 'GoalType.daily',
          'targetMinutes': 60,
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': true,
        },
        {
          'id': '2',
          'title': 'Complete 10 pomodoros',
          'type': 'GoalType.weekly',
          'targetMinutes': 250,
          'createdAt': DateTime.now().toIso8601String(),
          'completedAt': DateTime.now().toIso8601String(),
          'isActive': false,
        },
      ];

      when(mockRepository.loadGoals()).thenAnswer((_) async => goalsData);

      await provider.init();

      expect(provider.goals.length, 2);
      expect(provider.activeGoals.length, 1);
      expect(provider.completedGoals.length, 1);
      verify(mockRepository.loadGoals()).called(1);
    });

    test('Add new goal', () async {
      await provider.init();

      await provider.addGoal(
        title: 'Study 120 minutes',
        type: GoalType.daily,
        targetMinutes: 120,
      );

      expect(provider.goals.length, 1);
      expect(provider.goals.first.title, 'Study 120 minutes');
      expect(provider.goals.first.targetMinutes, 120);
      verify(mockRepository.saveGoals(any)).called(1);
    });

    test('Update goal', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Original Title',
        type: GoalType.daily,
        targetMinutes: 60,
      );

      final goalId = provider.goals.first.id;
      await provider.updateGoal(
        goalId,
        title: 'Updated Title',
        targetMinutes: 90,
      );

      expect(provider.goals.first.title, 'Updated Title');
      expect(provider.goals.first.targetMinutes, 90);
      verify(mockRepository.saveGoals(any)).called(2); // add + update
    });

    test('Complete goal', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Test Goal',
        type: GoalType.daily,
        targetMinutes: 60,
      );

      final goalId = provider.goals.first.id;
      await provider.completeGoal(goalId);

      expect(provider.goals.first.isActive, false);
      expect(provider.goals.first.completedAt, isNotNull);
      expect(provider.completedGoals.length, 1);
      expect(provider.activeGoals.length, 0);
    });

    test('Delete goal', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Test Goal',
        type: GoalType.daily,
        targetMinutes: 60,
      );

      final goalId = provider.goals.first.id;
      await provider.deleteGoal(goalId);

      expect(provider.goals.length, 0);
      verify(mockRepository.saveGoals(any)).called(2); // add + delete
    });

    test('Reactivate goal', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Test Goal',
        type: GoalType.daily,
        targetMinutes: 60,
      );

      final goalId = provider.goals.first.id;
      await provider.completeGoal(goalId);
      expect(provider.goals.first.isActive, false);

      await provider.reactivateGoal(goalId);
      expect(provider.goals.first.isActive, true);
      expect(provider.goals.first.completedAt, null);
      expect(provider.activeGoals.length, 1);
    });

    test('Get goals by type', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Daily Goal',
        type: GoalType.daily,
        targetMinutes: 60,
      );
      await provider.addGoal(
        title: 'Weekly Goal',
        type: GoalType.weekly,
        targetMinutes: 300,
      );

      final dailyGoals = provider.getGoalsByType(GoalType.daily);
      final weeklyGoals = provider.getGoalsByType(GoalType.weekly);

      expect(dailyGoals.length, 1);
      expect(weeklyGoals.length, 1);
      expect(dailyGoals.first.title, 'Daily Goal');
      expect(weeklyGoals.first.title, 'Weekly Goal');
    });

    test('Get current minutes for daily goal', () {
      final goal = Goal(
        id: '1',
        title: 'Daily Goal',
        type: GoalType.daily,
        targetMinutes: 60,
        createdAt: DateTime.now(),
      );

      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day)
          .toIso8601String()
          .split('T')[0];

      final dailyStats = {
        todayKey: DailyStatistics(
          date: today,
          totalStudyMinutes: 45,
          totalBreakMinutes: 15,
          completedCycles: 3,
          sessionIds: [],
        ),
      };

      final minutes = provider.getCurrentMinutes(goal, dailyStats);
      expect(minutes, 45);
    });

    test('Reset daily goals', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Daily Goal',
        type: GoalType.daily,
        targetMinutes: 60,
      );
      await provider.addGoal(
        title: 'Weekly Goal',
        type: GoalType.weekly,
        targetMinutes: 300,
      );

      final dailyGoalId = provider.goals
          .firstWhere((g) => g.type == GoalType.daily)
          .id;
      await provider.completeGoal(dailyGoalId);

      await provider.resetDailyGoals();

      final dailyGoal = provider.goals.firstWhere((g) => g.type == GoalType.daily);
      expect(dailyGoal.isActive, true);
      expect(dailyGoal.completedAt, null);
    });

    test('Reset weekly goals', () async {
      await provider.init();
      await provider.addGoal(
        title: 'Weekly Goal',
        type: GoalType.weekly,
        targetMinutes: 300,
      );

      final goalId = provider.goals.first.id;
      await provider.completeGoal(goalId);

      await provider.resetWeeklyGoals();

      expect(provider.goals.first.isActive, true);
      expect(provider.goals.first.completedAt, null);
    });
  });
}
