import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/break_activity.dart';
import '../models/pomodoro_session.dart';
import '../providers/break_activities_provider.dart';
import '../providers/timer_provider.dart';

class BreakActivitiesScreen extends StatefulWidget {
  const BreakActivitiesScreen({super.key});

  @override
  State<BreakActivitiesScreen> createState() => _BreakActivitiesScreenState();
}

class _BreakActivitiesScreenState extends State<BreakActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hoạt động giải lao',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: 'Vận động'),
            Tab(icon: Icon(Icons.spa), text: 'Thư giãn'),
            Tab(icon: Icon(Icons.people), text: 'Xã hội'),
            Tab(icon: Icon(Icons.palette), text: 'Sáng tạo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab(ActivityCategory.physical),
          _buildCategoryTab(ActivityCategory.mental),
          _buildCategoryTab(ActivityCategory.social),
          _buildCategoryTab(ActivityCategory.creative),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(ActivityCategory category) {
    return Consumer2<BreakActivitiesProvider, TimerProvider>(
      builder: (context, provider, timerProvider, _) {
        final activities = provider.getActivitiesByCategory(category);
        final stats = provider.getActivityStats();
        final suggestion = provider.suggestedActivity;
        final isBreak = timerProvider.currentType == SessionType.breakTime;
        final breakDuration = timerProvider.selectedTheme?.breakMinutes ?? 5;

        // Nếu đang nghỉ và không có gợi ý, tạo gợi ý mới
        if (suggestion == null && isBreak) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.suggestActivity(breakDuration);
          });
        }

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có hoạt động',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length + (isBreak && suggestion != null && suggestion.category == category ? 1 : 0),
          itemBuilder: (context, index) {
            // Hiển thị gợi ý đầu tiên nếu đang nghỉ
            if (isBreak && suggestion != null && suggestion.category == category && index == 0) {
              final count = stats[suggestion.id] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                color: suggestion.getCategoryColor().withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: suggestion.getCategoryColor(),
                    width: 2,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: suggestion.getCategoryColor().withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.stars,
                      color: suggestion.getCategoryColor(),
                      size: 28,
                    ),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.recommend, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text(
                        'Gợi ý cho bạn',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(suggestion.description),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${suggestion.durationMinutes} phút',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đã làm $count lần',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Hiển thị timer nếu đang chạy activity này
                      if (provider.runningActivity?.id == suggestion.id) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: suggestion.getCategoryColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${provider.remainingSeconds ~/ 60}:${(provider.remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () {
                                  provider.stopActivity();
                                },
                                icon: const Icon(Icons.stop, size: 16),
                                label: const Text('Dừng'),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  provider.skipSuggestion(breakDuration);
                                },
                                icon: const Icon(Icons.skip_next, size: 16),
                                label: const Text('Đổi khác', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: provider.isRunning ? null : () {
                                  provider.startActivity(suggestion.id);
                                },
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Bắt đầu', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  backgroundColor: suggestion.getCategoryColor(),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            final activityIndex = isBreak && suggestion != null && suggestion.category == category ? index - 1 : index;
            final activity = activities[activityIndex];
            final count = stats[activity.id] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activity.getCategoryColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activity.icon,
                    color: activity.getCategoryColor(),
                    size: 28,
                  ),
                ),
                title: Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(activity.description),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.durationMinutes} phút',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Đã làm $count lần',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Hiển thị timer nếu đang chạy
                    if (provider.runningActivity?.id == activity.id) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: activity.getCategoryColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${provider.remainingSeconds ~/ 60}:${(provider.remainingSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: isBreak
                    ? (provider.runningActivity?.id == activity.id
                        ? IconButton(
                            icon: const Icon(Icons.stop),
                            color: Colors.red,
                            onPressed: () {
                              provider.stopActivity();
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.play_arrow),
                            color: activity.getCategoryColor(),
                            onPressed: provider.isRunning ? null : () {
                              provider.startActivity(activity.id);
                            },
                          ))
                    : null,
                onTap: isBreak && !provider.isRunning
                    ? () {
                        provider.startActivity(activity.id);
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
