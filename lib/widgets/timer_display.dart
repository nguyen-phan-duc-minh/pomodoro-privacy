import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/pomodoro_session.dart';
import 'circular_timer_painter.dart';

class TimerDisplay extends StatelessWidget {
  final bool focusMode;

  const TimerDisplay({super.key, this.focusMode = false});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, child) {
        final session = timerProvider.currentSession;
        final theme = timerProvider.selectedTheme;

        if (theme == null) {
          return const Center(child: Text('Vui lòng chọn theme học'));
        }

        final isStudyPhase = session?.currentType == SessionType.study;
        final remainingTime = session != null
            ? timerProvider.remainingTime
            : theme.studyMinutes * 60;
        final studyProgress = session?.studyProgress ?? 0;
        final breakProgress = session?.breakProgress ?? 0;

        final primaryColor = focusMode
            ? Colors.white
            : Theme.of(context).colorScheme.primary;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (session != null)
                Column(
                  children: [
                    Text(
                      'Vòng ${session.completedCycles + 1}/${session.targetCycles}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isStudyPhase
                          ? 'HỌC'
                          : (timerProvider.currentActivityName ?? 'NGHỈ'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: focusMode
                                ? (isStudyPhase
                                      ? Colors.orange
                                      : Colors.lightBlue)
                                : (isStudyPhase
                                      ? theme.studyColor
                                      : theme.breakColor),
                            letterSpacing: timerProvider.hasActivity ? 1 : 2,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              SizedBox(
                width: 350,
                height: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(350, 350),
                      painter: CircularTimerPainter(
                        studyProgress: studyProgress,
                        breakProgress: breakProgress,
                        studyColor: theme.studyColor,
                        breakColor: theme.breakColor,
                        backgroundColor: theme.backgroundColor,
                        isStudyPhase: isStudyPhase,
                      ),
                    ),

                    Text(
                      _formatTime(remainingTime),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 72,
                        color: focusMode
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(
                    context,
                    'Học',
                    theme.studyColor,
                    '${theme.studyMinutes}p',
                  ),
                  const SizedBox(width: 30),
                  _buildLegend(
                    context,
                    'Nghỉ',
                    theme.breakColor,
                    '${theme.breakMinutes}p',
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _buildProgressIndicators(
                context,
                theme,
                studyProgress,
                breakProgress,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(
    BuildContext context,
    String label,
    Color color,
    String time,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($time)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildProgressIndicators(
    BuildContext context,
    dynamic theme,
    double studyProgress,
    double breakProgress,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.school, color: theme.studyColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: studyProgress,
                    backgroundColor: theme.studyColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.studyColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(studyProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.studyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.coffee, color: theme.breakColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: breakProgress,
                    backgroundColor: theme.breakColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.breakColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(breakProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.breakColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
