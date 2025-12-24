import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/break_activities_provider.dart';
import 'package:promodo_study/models/break_activity.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IBreakActivityRepository])
import 'break_activities_provider_test.mocks.dart';

void main() {
  group('BreakActivitiesProvider Tests', () {
    late BreakActivitiesProvider provider;
    late MockIBreakActivityRepository mockRepository;

    setUp(() {
      mockRepository = MockIBreakActivityRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadSelectedActivity()).thenAnswer((_) async => null);
      when(mockRepository.saveSelectedActivity(any)).thenAnswer((_) async {});
      
      provider = BreakActivitiesProvider(mockRepository);
    });

    test('Initialize loads default activities', () async {
      await provider.init();

      expect(provider.activities.length, greaterThan(0));
      verify(mockRepository.loadSelectedActivity()).called(1);
    });

    test('Initialize with saved activity', () async {
      final activityId = DefaultActivities.getAll().first.id;
      when(mockRepository.loadSelectedActivity())
          .thenAnswer((_) async => activityId);

      await provider.init();

      expect(provider.suggestedActivity, isNotNull);
      expect(provider.suggestedActivity?.id, activityId);
    });

    test('Suggest activity for break duration', () async {
      await provider.init();

      provider.suggestActivity(10);

      expect(provider.suggestedActivity, isNotNull);
      expect(
        provider.suggestedActivity!.durationMinutes,
        lessThanOrEqualTo(10),
      );
      verify(mockRepository.saveSelectedActivity(any)).called(1);
    });

    test('Suggest activity - no suitable activity', () async {
      await provider.init();

      provider.suggestActivity(1); // Too short for any activity

      expect(provider.suggestedActivity, null);
    });

    test('Skip suggestion', () async {
      await provider.init();

      provider.suggestActivity(15);
      final firstActivity = provider.suggestedActivity;

      provider.skipSuggestion(15);
      final secondActivity = provider.suggestedActivity;

      expect(secondActivity, isNotNull);
      // Should be different (might be same by chance but very unlikely)
      if (provider.activities.length > 1) {
        expect(secondActivity?.id != firstActivity?.id || firstActivity == null, true);
      }
      verify(mockRepository.saveSelectedActivity(any)).called(greaterThanOrEqualTo(2));
    });

    test('Clear suggestion', () async {
      await provider.init();

      provider.suggestActivity(10);
      expect(provider.suggestedActivity, isNotNull);

      provider.clearSuggestion();
      expect(provider.suggestedActivity, null);
      verify(mockRepository.saveSelectedActivity(null)).called(1);
    });

    test('Suggest activities by category', () async {
      await provider.init();

      final suggestions = provider.suggestActivitiesByCategory(15);

      expect(suggestions, isNotEmpty);
      expect(suggestions.keys.length, greaterThan(0));
      
      for (final entry in suggestions.entries) {
        expect(entry.value.category, entry.key);
        expect(entry.value.durationMinutes, lessThanOrEqualTo(15));
      }
    });

    test('Suggest activities by category with short break', () async {
      await provider.init();

      final suggestions = provider.suggestActivitiesByCategory(3);

      // Should only include activities that fit in 3 minutes
      for (final activity in suggestions.values) {
        expect(activity.durationMinutes, lessThanOrEqualTo(3));
      }
    });

    test('Start activity', () async {
      await provider.init();

      final activity = provider.activities.first;
      provider.startActivity(activity.id);

      expect(provider.runningActivity, isNotNull);
      expect(provider.runningActivity?.id, activity.id);
      expect(provider.isRunning, true);
      expect(provider.remainingSeconds, activity.durationMinutes * 60);
    });

    test('Stop activity', () async {
      await provider.init();

      final activity = provider.activities.first;
      provider.startActivity(activity.id);
      expect(provider.isRunning, true);

      provider.stopActivity();

      expect(provider.runningActivity, null);
      expect(provider.isRunning, false);
      expect(provider.remainingSeconds, 0);
    });

    test('Complete activity', () async {
      await provider.init();

      final activity = provider.activities.first;
      await provider.completeActivity(activity.id);

      expect(provider.history.length, 1);
      expect(provider.history.first.activityId, activity.id);
    });

    test('Get activities by category', () async {
      await provider.init();

      final physicalActivities = provider.getActivitiesByCategory(
        ActivityCategory.physical,
      );
      final mentalActivities = provider.getActivitiesByCategory(
        ActivityCategory.mental,
      );

      expect(physicalActivities.length, greaterThan(0));
      expect(mentalActivities.length, greaterThan(0));
      expect(
        physicalActivities.every((a) => a.category == ActivityCategory.physical),
        true,
      );
      expect(
        mentalActivities.every((a) => a.category == ActivityCategory.mental),
        true,
      );
    });

    test('Get activity stats', () async {
      await provider.init();

      final activity1 = provider.activities[0];
      final activity2 = provider.activities[1];

      await provider.completeActivity(activity1.id);
      await provider.completeActivity(activity1.id);
      await provider.completeActivity(activity2.id);

      final stats = provider.getActivityStats();

      expect(stats[activity1.id], 2);
      expect(stats[activity2.id], 1);
    });

    test('Get most frequent activity', () async {
      await provider.init();

      final activity1 = provider.activities[0];
      final activity2 = provider.activities[1];

      await provider.completeActivity(activity1.id);
      await provider.completeActivity(activity1.id);
      await provider.completeActivity(activity2.id);

      final mostFrequent = provider.getMostFrequentActivity();

      expect(mostFrequent?.id, activity1.id);
    });

    test('Get most frequent activity - empty history', () async {
      await provider.init();

      final mostFrequent = provider.getMostFrequentActivity();

      expect(mostFrequent, null);
    });

    test('Get today activity count', () async {
      await provider.init();

      expect(provider.getTodayActivityCount(), 0);

      final activity = provider.activities.first;
      await provider.completeActivity(activity.id);
      await provider.completeActivity(activity.id);

      expect(provider.getTodayActivityCount(), 2);
    });

    test('Add activity', () async {
      await provider.init();

      final initialCount = provider.activities.length;

      final newActivity = BreakActivity(
        id: 'custom-1',
        name: 'Custom Activity',
        description: 'A custom break activity',
        category: ActivityCategory.social,
        durationMinutes: 10,
        icon: Icons.chat,
      );

      await provider.addActivity(newActivity);

      expect(provider.activities.length, initialCount + 1);
      expect(provider.activities.last.name, 'Custom Activity');
    });

    test('Remove activity', () async {
      await provider.init();

      final initialCount = provider.activities.length;
      final activityId = provider.activities.first.id;

      await provider.removeActivity(activityId);

      expect(provider.activities.length, initialCount - 1);
      expect(
        provider.activities.any((a) => a.id == activityId),
        false,
      );
    });
  });
}
