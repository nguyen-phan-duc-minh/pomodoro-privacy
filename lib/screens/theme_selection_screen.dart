import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_theme.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/app_theme_provider.dart';
import 'timer_screen.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      
      if (timerProvider.selectedTheme == null && themeProvider.allThemes.isNotEmpty) {
        timerProvider.setTheme(themeProvider.allThemes.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final timerProvider = Provider.of<TimerProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chọn Theme Học',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.palette_outlined),
                      iconSize: 32,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => _showAppThemeDialog(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      iconSize: 40,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => _showCreateThemeDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: themeProvider.allThemes.length,
                    itemBuilder: (context, index) {
                      final theme = themeProvider.allThemes[index];
                      final isSelected =
                          timerProvider.selectedTheme?.id == theme.id;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _ThemeCard(
                          theme: theme,
                          isSelected: isSelected,
                          onTap: () {
                            timerProvider.setTheme(theme);
                          },
                          onLongPress: theme.isDefault
                              ? null
                              : () => _showDeleteThemeDialog(context, theme),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: timerProvider.selectedTheme == null
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TimerScreen(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bắt đầu học',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final StudyTheme theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 18,
                        color: theme.studyColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Học: ${theme.studyMinutes}p',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.coffee_rounded,
                        size: 18,
                        color: theme.breakColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Nghỉ: ${theme.breakMinutes}p',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (!theme.isDefault)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 25,
                    color: Colors.yellow,
                    onPressed: () => _showEditThemeDialog(context, theme),
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 25,
                    color: Colors.red,
                    onPressed: onLongPress,
                    tooltip: 'Xóa theme',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteThemeDialog(BuildContext context, StudyTheme theme) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Xóa Theme'),
      content: Text('Bạn có chắc muốn xóa theme "${theme.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            final timerProvider = Provider.of<TimerProvider>(context, listen: false);
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            
            if (timerProvider.selectedTheme?.id == theme.id) {
              timerProvider.setTheme(StudyTheme.defaultThemes.first);
            }
            
            await themeProvider.deleteCustomTheme(theme.id);
            
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xóa theme!')),
            );
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

void _showEditThemeDialog(BuildContext context, StudyTheme theme) {
  final nameController = TextEditingController(text: theme.name);
  final studyController = TextEditingController(text: theme.studyMinutes.toString());
  final breakController = TextEditingController(text: theme.breakMinutes.toString());
  
  Color studyColor = theme.studyColor;
  Color breakColor = theme.breakColor;
  Color bgColor = theme.backgroundColor;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Chỉnh sửa Theme'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên theme',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: studyController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian học (phút)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: breakController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian nghỉ (phút)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _ColorPickerRow(
                  label: 'Màu học',
                  color: studyColor,
                  onColorChanged: (color) => setState(() => studyColor = color),
                ),
                const SizedBox(height: 16),
                _ColorPickerRow(
                  label: 'Màu nghỉ',
                  color: breakColor,
                  onColorChanged: (color) => setState(() => breakColor = color),
                ),
                const SizedBox(height: 16),
                _ColorPickerRow(
                  label: 'Màu nền',
                  color: bgColor,
                  onColorChanged: (color) => setState(() => bgColor = color),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final study = int.tryParse(studyController.text);
              final breakTime = int.tryParse(breakController.text);

              if (name.isEmpty || study == null || breakTime == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
                );
                return;
              }

              final updatedTheme = StudyTheme(
                id: theme.id,
                name: name,
                studyMinutes: study,
                breakMinutes: breakTime,
                studyColor: studyColor,
                breakColor: breakColor,
                backgroundColor: bgColor,
                isDefault: false,
              );

              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              final timerProvider = Provider.of<TimerProvider>(context, listen: false);
              
              await themeProvider.updateCustomTheme(updatedTheme);
              
              if (timerProvider.selectedTheme?.id == theme.id) {
                timerProvider.setTheme(updatedTheme);
              }

              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật theme!')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ),
  );
}

void _showCreateThemeDialog(BuildContext context) {
  final nameController = TextEditingController();
  final studyController = TextEditingController(text: '25');
  final breakController = TextEditingController(text: '5');
  
  Color studyColor = Colors.orange;
  Color breakColor = Colors.cyan;
  Color bgColor = Colors.grey.shade100;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (stateContext, setState) => AlertDialog(
        title: const Text(
          'Tạo Theme Mới',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên theme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: studyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Học (phút)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: breakController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nghỉ (phút)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ColorPickerRow(
                label: 'Màu học',
                color: studyColor,
                onColorChanged: (color) {
                  setState(() => studyColor = color);
                },
              ),
              const SizedBox(height: 10),
              _ColorPickerRow(
                label: 'Màu nghỉ',
                color: breakColor,
                onColorChanged: (color) {
                  setState(() => breakColor = color);
                },
              ),
              const SizedBox(height: 10),
              _ColorPickerRow(
                label: 'Màu nền',
                color: bgColor,
                onColorChanged: (color) {
                  setState(() => bgColor = color);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên theme')),
                );
                return;
              }

              final studyMinutes = int.tryParse(studyController.text);
              final breakMinutes = int.tryParse(breakController.text);

              if (studyMinutes == null || studyMinutes < 1 || studyMinutes > 120) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thời gian học phải từ 1-120 phút')),
                );
                return;
              }

              if (breakMinutes == null || breakMinutes < 1 || breakMinutes > 60) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thời gian nghỉ phải từ 1-60 phút')),
                );
                return;
              }

              await Provider.of<ThemeProvider>(context, listen: false)
                  .addCustomTheme(
                name: nameController.text.trim(),
                studyMinutes: studyMinutes,
                breakMinutes: breakMinutes,
                studyColor: studyColor,
                breakColor: breakColor,
                backgroundColor: bgColor,
              );

              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã tạo theme mới!')),
                );
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    ),
  );
}

void _showAppThemeDialog(BuildContext context) {
  final appThemeProvider = Provider.of<AppThemeProvider>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Chọn Giao Diện'),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.defaultThemes.map((theme) {
            final isSelected = appThemeProvider.currentTheme.id == theme.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: Icon(
                    Icons.palette,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  theme.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () {
                  appThemeProvider.setTheme(theme);
                  Navigator.of(dialogContext).pop();
                },
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}

class _ColorPickerRow extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerRow({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((c) {
              final isSelected = c.toARGB32() == color.toARGB32();
              return GestureDetector(
              onTap: () => onColorChanged(c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
      ),
    );
  }
}
