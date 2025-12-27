import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final Set<String> _selectedTaskIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.onTaskCompleted = (task) {
        _showTaskCompletedDialog(context, task);
      };
    });
  }

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTaskIds.add(taskId);
        _isSelectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelectedTasks(BuildContext context) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Xóa nhiệm vụ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedTaskIds.length} nhiệm vụ đã chọn?',
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
      for (final taskId in _selectedTaskIds) {
        await taskProvider.deleteTask(taskId);
      }
      _cancelSelection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ${_selectedTaskIds.length} nhiệm vụ'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showTaskCompletedDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
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
              'Bạn đã hoàn thành nhiệm vụ:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"${task.title}"',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (task.pomodorosCompleted > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${task.pomodorosCompleted} Pomodoro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? '${_selectedTaskIds.length} đã chọn' : 'Nhiệm vụ',
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
                  onPressed: () => _deleteSelectedTasks(context),
                ),
              ]
            : [
                Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) {
                    if (taskProvider.completedTasks.isEmpty)
                      return const SizedBox();
                    return IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      onPressed: () =>
                          _showClearCompletedDialog(context, taskProvider),
                      tooltip: 'Xóa đã hoàn thành',
                    );
                  },
                ),
              ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có nhiệm vụ nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn + để thêm nhiệm vụ',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (taskProvider.activeTasks.isNotEmpty) ...[
                Text(
                  'Đang làm (${taskProvider.activeTasks.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...taskProvider.activeTasks.map(
                  (task) => _TaskItem(
                    task: task,
                    isSelected: _selectedTaskIds.contains(task.id),
                    isSelectionMode: _isSelectionMode,
                    onSelectionToggle: () => _toggleSelection(task.id),
                    onLongPress: () => _toggleSelection(task.id),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (taskProvider.completedTasks.isNotEmpty) ...[
                Text(
                  'Hoàn thành (${taskProvider.completedTasks.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                ...taskProvider.completedTasks.map(
                  (task) => _TaskItem(
                    task: task,
                    isSelected: _selectedTaskIds.contains(task.id),
                    isSelectionMode: _isSelectionMode,
                    onSelectionToggle: () => _toggleSelection(task.id),
                    onLongPress: () => _toggleSelection(task.id),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhiệm vụ'),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Thêm nhiệm vụ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tên nhiệm vụ...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Provider.of<TaskProvider>(
                context,
                listen: false,
              ).addTask(value.trim());
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).addTask(controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(
    BuildContext context,
    TaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Xóa nhiệm vụ đã hoàn thành',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          'Xóa ${taskProvider.completedTasks.length} nhiệm vụ đã hoàn thành?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.clearCompletedTasks();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onSelectionToggle;
  final VoidCallback onLongPress;

  const _TaskItem({
    required this.task,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onSelectionToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isActive = taskProvider.activeTask?.id == task.id;

    return GestureDetector(
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
                : (isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300),
            width: isSelected ? 3 : (isActive ? 2 : 1),
          ),
        ),
        child: ListTile(
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => onSelectionToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : (task.completed
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28,
                      )
                    : null),
          onTap: isSelectionMode
              ? onSelectionToggle
              : () {
                  if (!task.completed) {
                    if (isActive) {
                      taskProvider.setActiveTask(null);
                    } else {
                      taskProvider.setActiveTask(task.id);
                    }
                  }
                },
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: task.completed ? Colors.grey.shade500 : null,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: task.studyMinutes > 0
              ? Text(
                  'Time: ${task.studyMinutes >= 60 ? "${(task.studyMinutes / 60).floor()}h${task.studyMinutes % 60 > 0 ? " ${task.studyMinutes % 60}p" : ""}" : "${task.studyMinutes}p"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    _showEditDialog(context, task);
                  } else if (value == 'delete') {
                    taskProvider.deleteTask(task.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, task) {
    final controller = TextEditingController(text: task.title);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Sửa nhiệm vụ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                taskProvider.updateTask(task.id, controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
