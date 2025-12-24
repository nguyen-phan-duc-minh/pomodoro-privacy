import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/task_provider.dart';
import '../providers/break_activities_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import 'focus_mode_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final originalOnCycleComplete = timerProvider.onCycleComplete;
      timerProvider.onCycleComplete = () {
        originalOnCycleComplete?.call();

        if (taskProvider.activeTask != null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showTaskCompletionDialog(
                context,
                taskProvider.activeTask!,
                taskProvider,
              );
            }
          });
        }
      };

      timerProvider.onBreakActivityNeeded = () {
        if (!mounted) return;
        _showBreakActivityDialog(context, timerProvider);
      };
    });
  }

  Future<void> _showBreakActivityDialog(
    BuildContext context,
    TimerProvider timerProvider,
  ) async {
    final breakActivitiesProvider = Provider.of<BreakActivitiesProvider>(
      context,
      listen: false,
    );
    final breakDuration = timerProvider.selectedTheme?.breakMinutes ?? 5;
    final suggestions = breakActivitiesProvider.suggestActivitiesByCategory(
      breakDuration,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Giờ nghỉ! Chọn hoạt động?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestions.isNotEmpty) ...[
                const Text(
                  'Gợi ý hoạt động cho bạn:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...suggestions.entries.map((entry) {
                  final activity = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        timerProvider.setBreakActivity(
                          activity.id,
                          activity.name,
                          activity.durationMinutes,
                        );
                        breakActivitiesProvider.startActivity(activity.id);
                        timerProvider.resumeSession();
                        Navigator.of(dialogContext).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: activity.getCategoryColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: activity.getCategoryColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              activity.icon,
                              color: activity.getCategoryColor(),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activity.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: activity.getCategoryColor(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${activity.durationMinutes}\'',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ] else ...[
                const Text(
                  'Không có hoạt động phù hợp với thời gian nghỉ.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              timerProvider.skipBreakActivity();
              timerProvider.resumeSession();
              Navigator.of(dialogContext).pop();
            },
            child: Text('Nghỉ bình thường ($breakDuration phút)'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskCompletionDialog(
    BuildContext context,
    dynamic task,
    TaskProvider taskProvider,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Hoàn thành nhiệm vụ?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${task.title}"',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '⏱ ${task.studyMinutes >= 60 ? "${(task.studyMinutes / 60).floor()}h${task.studyMinutes % 60 > 0 ? " ${task.studyMinutes % 60}p" : ""}" : "${task.studyMinutes}p"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Chưa xong'),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.completeTask(task.id);
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Xác nhận thoát',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text('Bạn có muốn quay lại màn hình chọn theme?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Consumer<TimerProvider>(
                      builder: (context, timerProvider, _) {
                        return IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () async {
                            if (timerProvider.isRunning ||
                                timerProvider.isPaused) {
                              final shouldExit = await _showExitDialog(context);
                              if (shouldExit && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    Consumer<TimerProvider>(
                      builder: (context, timerProvider, _) {
                        if (!timerProvider.isRunning) return const SizedBox();

                        return IconButton(
                          icon: const Icon(Icons.center_focus_strong),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FocusModeScreen(),
                              ),
                            );
                          },
                          tooltip: 'Focus Mode',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Consumer<TimerProvider>(
                      builder: (context, timerProvider, child) {
                        final theme = timerProvider.selectedTheme;
                        if (theme == null) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.studyColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.breakColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                theme.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Expanded(child: Center(child: TimerDisplay())),
              const TimerControls(),
            ],
          ),
        ),
      ),
    );
  }
}
