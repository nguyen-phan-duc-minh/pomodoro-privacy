import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../services/widget_service.dart';

class WidgetSettingsScreen extends StatelessWidget {
  const WidgetSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt Widget',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hướng dẫn thêm widget
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.widgets,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Thêm Widget',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Để thêm Pomodoro widget vào màn hình chính:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Nhấn giữ vào màn hình chính'),
                    _buildStep('2', 'Chọn "Widgets" hoặc biểu tượng +'),
                    _buildStep('3', 'Tìm "Pomodoro Study"'),
                    _buildStep('4', 'Kéo widget vào vị trí mong muốn'),
                    const SizedBox(height: 12),
                    Text(
                      'Widget sẽ hiển thị timer hiện tại và thống kê học tập của bạn!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Thông tin widget hiển thị
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Widget hiển thị:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(Icons.timer, 'Thời gian còn lại'),
                    _buildInfoItem(Icons.school, 'Loại phiên (Học tập/Nghỉ)'),
                    _buildInfoItem(Icons.palette, 'Tên theme đang dùng'),
                    _buildInfoItem(Icons.task_alt, 'Nhiệm vụ đang thực hiện'),
                    _buildInfoItem(Icons.emoji_events, 'Số Pomodoro hôm nay'),
                    _buildInfoItem(Icons.local_fire_department, 'Streak hiện tại'),
                    _buildInfoItem(Icons.access_time, 'Tổng phút học hôm nay'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Preview thống kê hiện tại
            Consumer<StatisticsProvider>(
              builder: (context, statsProvider, _) {
                final todayStats = statsProvider.todayStats;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thống kê hiện tại:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle,
                                color: Colors.orange,
                                value: todayStats.completedCycles.toString(),
                                label: 'Pomodoros',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.local_fire_department,
                                color: Colors.pink,
                                value: statsProvider.currentStreak.toString(),
                                label: 'Streak',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.timer,
                                color: Colors.blue,
                                value: todayStats.totalStudyMinutes.toString(),
                                label: 'Phút',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Nút cập nhật widget thủ công
            ElevatedButton.icon(
              onPressed: () async {
                final statsProvider = context.read<StatisticsProvider>();
                final todayStats = statsProvider.todayStats;
                
                await WidgetService.updateStatistics(
                  todayPomodoros: todayStats.completedCycles,
                  todayMinutes: todayStats.totalStudyMinutes,
                  currentStreak: statsProvider.currentStreak,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật widget! 📱'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Cập nhật Widget'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Widget sẽ tự động cập nhật khi timer thay đổi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
