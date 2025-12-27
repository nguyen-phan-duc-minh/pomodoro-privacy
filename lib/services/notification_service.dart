import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/interfaces.dart';

class NotificationService implements INotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  Future<void> showStudyStartNotification() async {
    await _showNotification(
      id: 1,
      title: 'Bắt đầu học',
      body: 'Hãy tập trung và học thật tốt!',
    );
  }

  Future<void> showStudyCompleteNotification() async {
    await _showNotification(
      id: 2,
      title: 'Hoàn thành học',
      body: 'Tuyệt vời! Giờ nghỉ ngơi thôi.',
    );
  }

  Future<void> showBreakStartNotification() async {
    await _showNotification(
      id: 3,
      title: 'Giờ nghỉ',
      body: 'Thư giãn và nạp lại năng lượng!',
    );
  }

  Future<void> showBreakCompleteNotification() async {
    await _showNotification(
      id: 4,
      title: 'Hết giờ nghỉ',
      body: 'Sẵn sàng cho phiên học tiếp theo!',
    );
  }

  Future<void> showCycleCompleteNotification(int cycles) async {
    await _showNotification(
      id: 5,
      title: 'Hoàn thành!',
      body: 'Bạn đã hoàn thành $cycles vòng Pomodoro!',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Notifications for Pomodoro timer events',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
