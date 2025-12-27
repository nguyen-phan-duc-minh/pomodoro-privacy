import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/statistics_provider.dart';
import '../models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final Set<String> _selectedGoalIds = {};
  bool _isSelectionMode = false;

  void _toggleSelection(String goalId) {
    setState(() {
      if (_selectedGoalIds.contains(goalId)) {
        _selectedGoalIds.remove(goalId);
        if (_selectedGoalIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedGoalIds.add(goalId);
        _isSelectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedGoalIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedGoals(BuildContext context) async {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Xóa mục tiêu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedGoalIds.length} mục tiêu đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      for (final goalId in _selectedGoalIds) {
        await goalProvider.deleteGoal(goalId);
      }
      _cancelSelection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ${_selectedGoalIds.length} mục tiêu'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedGoalIds.length} đã chọn' : 'Mục tiêu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelection,
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSelectedGoals(context),
                ),
              ]
            : null,
      ),
      body: Consumer2<GoalProvider, StatisticsProvider>(
        builder: (context, goalProvider, statsProvider, _) {
          final activeGoals = goalProvider.activeGoals;
          final completedGoals = goalProvider.completedGoals;

          if (activeGoals.isEmpty && completedGoals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có mục tiêu nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn + để thêm mục tiêu',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeGoals.isNotEmpty) ...[
                Text(
                  'Đang thực hiện (${activeGoals.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...activeGoals.map(
                  (goal) => _GoalCard(
                    goal: goal,
                    currentMinutes: goalProvider.getCurrentMinutes(
                      goal,
                      statsProvider.statistics.dailyStats,
                    ),
                    onCompleted: () => _showGoalCompletedDialog(context, goal),
                    isSelected: _selectedGoalIds.contains(goal.id),
                    isSelectionMode: _isSelectionMode,
                    onSelectionToggle: () => _toggleSelection(goal.id),
                    onLongPress: () => _toggleSelection(goal.id),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (completedGoals.isNotEmpty) ...[
                Text(
                  'Hoàn thành (${completedGoals.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedGoals.map(
                  (goal) => _GoalCard(
                    goal: goal,
                    currentMinutes: goal.targetMinutes,
                    isCompleted: true,
                    isSelected: _selectedGoalIds.contains(goal.id),
                    isSelectionMode: _isSelectionMode,
                    onSelectionToggle: () => _toggleSelection(goal.id),
                    onLongPress: () => _toggleSelection(goal.id),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mục tiêu'),
      ),
    );
  }

  void _showGoalCompletedDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Chúc mừng!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bạn đã hoàn thành mục tiêu:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"${goal.title}"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(goal.targetMinutes / 60).toStringAsFixed(1)} giờ học tập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tiếp tục phấn đấu nhé!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Provider.of<GoalProvider>(
                  context,
                  listen: false,
                ).completeGoal(goal.id);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    GoalType selectedType = GoalType.daily;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Thêm mục tiêu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên mục tiêu',
                    hintText: 'Ví dụ: Học 4 tiếng mỗi ngày',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại mục tiêu',
                    border: OutlineInputBorder(),
                  ),
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text('${type.icon} ${type.displayName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tổng thời gian học (giờ)',
                    hintText: 'Ví dụ: 4',
                    border: OutlineInputBorder(),
                    suffixText: '',
                    helperText: '1 giờ = 60 phút',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    targetController.text.trim().isEmpty) {
                  return;
                }

                final targetHours = int.tryParse(targetController.text);
                if (targetHours == null || targetHours <= 0) return;

                Provider.of<GoalProvider>(context, listen: false).addGoal(
                  title: titleController.text.trim(),
                  type: selectedType,
                  targetMinutes: targetHours * 60,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final int currentMinutes;
  final bool isCompleted;
  final VoidCallback? onCompleted;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onSelectionToggle;
  final VoidCallback onLongPress;

  const _GoalCard({
    required this.goal,
    required this.currentMinutes,
    this.isCompleted = false,
    this.onCompleted,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onSelectionToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.getProgress(currentMinutes);
    final remaining = goal.getRemainingMinutes(currentMinutes);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    if (!isCompleted &&
        goal.isCompleted(currentMinutes) &&
        onCompleted != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onCompleted!();
      });
    }

    return GestureDetector(
      onTap: isSelectionMode ? onSelectionToggle : null,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isCompleted ? Colors.green : Colors.grey.shade300),
            width: isSelected ? 3 : (isCompleted ? 2 : 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onSelectionToggle(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          goal.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompleted)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Sửa'),
                            ],
                          ),
                        ),
                        if (goal.isCompleted(currentMinutes))
                          const PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text('Hoàn thành'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, goal);
                        } else if (value == 'complete') {
                          goalProvider.completeGoal(goal.id);
                        } else if (value == 'delete') {
                          goalProvider.deleteGoal(goal.id);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${(currentMinutes / 60).toStringAsFixed(1)}h / ${(goal.targetMinutes / 60).toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 1.0
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (!isCompleted && remaining > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Còn ${(remaining / 60).toStringAsFixed(1)} giờ nữa!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (isCompleted && goal.completedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Hoàn thành',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    final targetHours = (goal.targetMinutes / 60).toStringAsFixed(1);
    final targetController = TextEditingController(text: targetHours);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Sửa mục tiêu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên mục tiêu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tổng thời gian học (giờ)',
                border: OutlineInputBorder(),
                suffixText: '',
                helperText: '1 giờ = 60 phút',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  targetController.text.trim().isEmpty) {
                return;
              }

              final targetHours = double.tryParse(targetController.text);
              if (targetHours == null || targetHours <= 0) return;

              goalProvider.updateGoal(
                goal.id,
                title: titleController.text.trim(),
                targetMinutes: (targetHours * 60).toInt(),
              );

              Navigator.pop(dialogContext);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
