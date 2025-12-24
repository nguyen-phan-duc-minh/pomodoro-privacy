import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/timer_display.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _showControls = true;

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timerProvider = Provider.of<TimerProvider>(
          context,
          listen: false,
        );

        if (timerProvider.isRunning || timerProvider.isPaused) {
          final shouldExit = await _showExitDialog(context);
          return shouldExit;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.grey.shade900, Colors.black],
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildTopBar(context),
                    ),

                    const Expanded(
                      child: Center(child: TimerDisplay(focusMode: true)),
                    ),

                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _buildBottomControls(context),
                    ),
                  ],
                ),
              ),

              if (!_showControls)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: 0.3,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'Nhấn vào màn hình để hiện điều khiển',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              final shouldExit = await _showExitDialog(context);
              if (shouldExit && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.white),
            label: const Text(
              'Thoát',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Spacer(),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.activeTask == null) {
                return const SizedBox();
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.task_alt, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      taskProvider.activeTask!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Consumer<TimerProvider>(
            builder: (context, timerProvider, _) {
              final theme = timerProvider.selectedTheme;
              if (theme == null) return const SizedBox();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  theme.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        final isRunning = timerProvider.isRunning;
        final isPaused = timerProvider.isPaused;
        final isIdle = timerProvider.isIdle;
        final hasSession = timerProvider.currentSession != null;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isIdle || (!isRunning && !isPaused && !hasSession)) ...[
                _buildControlButton(
                  icon: Icons.play_arrow,
                  label: 'Bắt đầu',
                  color: Colors.green,
                  onPressed: () => _showStartDialog(context, timerProvider),
                ),
              ] else if (isRunning) ...[
                _buildControlButton(
                  icon: Icons.pause,
                  label: 'Tạm dừng',
                  color: Colors.orange,
                  onPressed: () => timerProvider.pauseSession(),
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.blue,
                  onPressed: () => _showResetDialog(context, timerProvider),
                ),
              ] else if (isPaused) ...[
                _buildControlButton(
                  icon: Icons.play_arrow,
                  label: 'Tiếp tục',
                  color: Colors.green,
                  onPressed: () => timerProvider.resumeSession(),
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.blue,
                  onPressed: () => _showResetDialog(context, timerProvider),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Thoát Focus Mode?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text('Bạn có muốn thoát khỏi chế độ tập trung?'),
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
                  _buildCycleButton(
                    context,
                    dialogContext,
                    i,
                    timerProvider,
                    studyMinutes,
                  ),
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
    BuildContext dialogContext,
    int cycles,
    TimerProvider timerProvider,
    int studyMinutes,
  ) {
    final totalStudyTime = cycles * studyMinutes;

    return InkWell(
      onTap: () {
        timerProvider.startSession(targetCycles: cycles);
        Navigator.pop(dialogContext);
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
