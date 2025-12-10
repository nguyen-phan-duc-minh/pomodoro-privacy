# Pomodoro Study Timer

Ứng dụng Pomodoro Timer dành cho việc học tập, được xây dựng bằng Flutter.

## Tính năng

### 🎯 Quản lý Theme Học Tập
- **4 Theme mặc định:**
  - Nhẹ (20 phút học / 5 phút nghỉ)
  - Vừa (30 phút học / 5 phút nghỉ)
  - Trung bình (45 phút học / 10 phút nghỉ)
  - Sâu (60 phút học / 15 phút nghỉ)
- Tạo theme tùy chỉnh với:
  - Tên theme
  - Thời gian học (1-120 phút)
  - Thời gian nghỉ (1-60 phút)
  - Màu sắc tùy chỉnh (học, nghỉ, nền)
- Xóa theme tùy chỉnh (long-press vào theme card)

### ⏱️ Timer Chức Năng Đầy Đủ
- Giao diện fullscreen (không có app bar/navigation bar)
- Dual concentric circles hiển thị tiến độ:
  - Vòng ngoài: Tiến độ học
  - Vòng trong: Tiến độ nghỉ
- Điều khiển timer:
  - Bắt đầu/Tạm dừng/Tiếp tục/Dừng
  - Thêm 5 phút học
  - Thêm 3 phút nghỉ
  - Chọn số chu kỳ mục tiêu (1-10)
- Tự động chuyển đổi giữa học và nghỉ
- Lưu trạng thái khi đóng app

### 🔔 Thông Báo & Âm Thanh
- Âm thanh beep cho các sự kiện:
  - Bắt đầu học
  - Hoàn thành học
  - Bắt đầu nghỉ
  - Hoàn thành nghỉ
  - Hoàn thành chu kỳ
- Thông báo push với Android Notification Service

### 🎨 4 App Themes
- Light Pastel
- Dark Neon
- Galaxy
- Campus

## Yêu Cầu

- Flutter SDK: 3.x trở lên
- Dart: 3.x trở lên
- Android: minSdk 21 trở lên

## Cài Đặt

1. Clone repository:
```bash
git clone <repo-url>
cd promodo_study
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. Chạy app:
```bash
flutter run
```

## Build Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (AAB)
```bash
flutter build appbundle --release
```

File output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Cấu Trúc Project

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── app_theme.dart
│   ├── pomodoro_session.dart
│   ├── study_statistics.dart
│   └── study_theme.dart
├── providers/                   # State management (Provider)
│   ├── app_theme_provider.dart
│   ├── statistics_provider.dart
│   ├── theme_provider.dart
│   └── timer_provider.dart
├── screens/                     # UI screens
│   ├── theme_selection_screen.dart
│   └── timer_screen.dart
├── services/                    # Services
│   ├── audio_service.dart
│   └── notification_service.dart
└── widgets/                     # Reusable widgets
    ├── circular_timer_painter.dart
    ├── timer_controls.dart
    └── timer_display.dart
```

## Dependencies

- `provider`: State management
- `shared_preferences`: Local storage
- `audioplayers`: Audio playback
- `flutter_local_notifications`: Push notifications
- `intl`: Date formatting (Vietnamese)
- `uuid`: Unique ID generation

## Build Configuration

### Signing (Android)
App đã được cấu hình signing với keystore tại `android/app/upload-keystore.jks`.

Thông tin signing được lưu trong `android/key.properties` (không commit lên git).

### ProGuard
ProGuard đã được bật để giảm kích thước app và bảo mật code.

### Privacy Policy
Privacy policy có tại: https://nguyen-phan-duc-minh.github.io/smarttoolkit-privacy/

## License

MIT License

## Author

Nguyen Phan Duc Minh
