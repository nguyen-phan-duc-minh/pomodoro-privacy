import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thống kê',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, stats, _) {
          final todayStats = stats.todayStats;
          final allStats = stats.statistics.dailyStats.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Hôm nay
                Row(
                  children: [
                    Expanded(child: _buildCard('Thời gian học', '${todayStats.totalStudyMinutes} phút', Icons.timer, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCard('Pomodoro', '${todayStats.completedCycles} vòng', Icons.check_circle, Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tổng quan
                Row(
                  children: [
                    Expanded(child: _buildCard('Tổng thời gian', '${stats.getTotalStudyMinutes()} phút', Icons.schedule, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCard('Tổng Pomodoro', '${stats.getTotalCompletedCycles()} vòng', Icons.repeat, Colors.purple)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Streak
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 48, color: Colors.orange.shade300),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Chuỗi ngày học', style: TextStyle(color: Colors.white, fontSize: 16)),
                            Text('${stats.currentStreak} ngày', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            Text('Kỷ lục: ${stats.longestStreak} ngày', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Lịch sử
                if (allStats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Chưa có lịch sử học tập'),
                  )
                else
                  ...allStats.take(30).map((stat) {
                    final isToday = _isToday(stat.date);
                    final dateStr = isToday ? 'Hôm nay' : DateFormat('dd/MM/yyyy').format(stat.date);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('${stat.totalStudyMinutes} phút • ${stat.completedCycles} vòng', 
                                  style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
