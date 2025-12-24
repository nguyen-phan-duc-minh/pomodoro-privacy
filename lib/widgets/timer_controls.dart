import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/task_provider.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final isRunning = timerProvider.isRunning;
        final isPaused = timerProvider.isPaused;
        final isIdle = timerProvider.isIdle;
        final hasSession = timerProvider.currentSession != null;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isIdle || (!isRunning && !isPaused && !hasSession)) ...[
                    _buildMainButton(
                      context,
                      icon: Icons.play_arrow_rounded,
                      label: 'Bắt đầu',
                      color: Colors.green,
                      onPressed: () => _showStartDialog(context, timerProvider),
                    ),
                  ] else if (isRunning) ...[
                    _buildMainButton(
                      context,
                      icon: Icons.pause_rounded,
                      label: 'Tạm dừng',
                      color: Colors.orange,
                      onPressed: () => timerProvider.pauseSession(),
                    ),
                    const SizedBox(width: 12),
                    _buildMainButton(
                      context,
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      color: Colors.blue,
                      onPressed: () => _showResetDialog(context, timerProvider),
                    ),
                  ] else if (isPaused) ...[
                    _buildMainButton(
                      context,
                      icon: Icons.play_arrow_rounded,
                      label: 'Tiếp tục',
                      color: Colors.green,
                      onPressed: () => timerProvider.resumeSession(),
                    ),
                    const SizedBox(width: 12),
                    _buildMainButton(
                      context,
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      color: Colors.blue,
                      onPressed: () => _showResetDialog(context, timerProvider),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
    );
  }

  void _showStartDialog(BuildContext context, TimerProvider timerProvider) {
    final studyMinutes = timerProvider.selectedTheme?.studyMinutes ?? 25;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Bắt đầu học',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn số vòng:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 4; i++) ...[
                  _buildCycleButton(context, i, timerProvider, studyMinutes),
                  if (i < 4) const SizedBox(width: 16),
                ],
              ],
            ),
            if (taskProvider.activeTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Nhiệm vụ (tùy chọn):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Consumer<TaskProvider>(
                builder: (context, provider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: provider.activeTask?.id,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        hint: const Text('Không chọn'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Không chọn'),
                          ),
                          ...provider.activeTasks.map((task) {
                            return DropdownMenuItem<String?>(
                              value: task.id,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (task.studyMinutes > 0)
                                    Text(
                                      ' ⏱️${task.studyMinutes}p',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          provider.setActiveTask(value);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleButton(
    BuildContext context,
    int cycles,
    TimerProvider timerProvider,
    int studyMinutes,
  ) {
    final totalStudyTime = cycles * studyMinutes;

    return InkWell(
      onTap: () {
        timerProvider.startSession(targetCycles: cycles);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$cycles',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${totalStudyTime}p',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, TimerProvider timerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset phiên học',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text(
          'Bạn có muốn reset phiên học về thời gian ban đầu?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await timerProvider.stopSession();
              if (!context.mounted) return;
              Navigator.pop(context);
              if (context.mounted) {
                _showStartDialog(context, timerProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
