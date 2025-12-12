# Pomodoro Study Timer

Ứng dụng Pomodoro Timer dành cho việc học tập, được xây dựng bằng Flutter với đầy đủ tính năng quản lý thời gian học tập, thống kê và theo dõi tiến độ.

## ✨ Tính năng

### 🎯 Quản lý Theme Học Tập
- **4 Theme mặc định:**
  - Nhẹ (20 phút học / 5 phút nghỉ)
  - Vừa (30 phút học / 5 phút nghỉ)
  - Trung bình (45 phút học / 10 phút nghỉ)
  - Sâu (60 phút học / 15 phút nghỉ)
- **Tạo theme tùy chỉnh** với:
  - Tên theme
  - Thời gian học (1-120 phút)
  - Thời gian nghỉ (1-60 phút)
  - Màu sắc tùy chỉnh cho học, nghỉ và nền (19 màu sắc)
- **Chỉnh sửa theme** tùy chỉnh
- **Xóa theme** tùy chỉnh (không thể xóa theme mặc định)
- Hiển thị tổng thời gian học khi chọn số vòng Pomodoro

### ⏱️ Timer Pomodoro
- **Giao diện trực quan:**
  - Hiển thị số vòng (vd: Vòng 1/3)
  - Trạng thái HỌC/NGHỈ
  - Đồng hồ đếm ngược lớn ở giữa vòng tròn
  - Dual progress bars hiển thị tiến độ học và nghỉ (%)
- **Vòng tròn tiến độ:**
  - Vòng ngoài (cam): Tiến độ học
  - Vòng trong (xanh): Tiến độ nghỉ
- **Điều khiển timer:**
  - Chọn số vòng (1-4 vòng) với hiển thị tổng thời gian
  - Bắt đầu/Tạm dừng/Tiếp tục
  - Reset phiên học
- **Tự động:**
  - Chuyển đổi từ học sang nghỉ
  - Chuyển từ nghỉ sang vòng học mới
  - Hoàn thành khi đủ số vòng đã chọn
- Lưu trạng thái real-time khi đang chạy

### 🔔 Thông Báo & Âm Thanh
- **Âm thanh ting (volume 100%) + rung điện thoại** cho:
  - Bắt đầu học
  - Hoàn thành học
  - Bắt đầu nghỉ
  - Hoàn thành nghỉ
  - Hoàn thành chu kỳ
- **Nhạc nền thư giãn (calming-rain-audio.mp3):**
  - Phát tự động khi bắt đầu học
  - Dừng tự động khi kết thúc học
  - Volume 30% để không át tiếng thông báo
- Thông báo nổi ở **đầu màn hình** (không phải dưới cùng)

### 📊 Thống kê Học Tập
- **Thống kê hôm nay:**
  - Thời gian học (phút)
  - Số vòng Pomodoro hoàn thành
- **Tổng quan:**
  - Tổng thời gian học (tất cả các ngày)
  - Tổng số vòng Pomodoro (tất cả các ngày)
- **Chuỗi ngày học (Streak):**
  - Số ngày học liên tục
  - Kỷ lục cá nhân (longest streak)
  - Hiển thị với icon lửa 🔥
- **Lịch sử học tập:**
  - Danh sách chi tiết 30 ngày gần nhất
  - Hiển thị thời gian học và số vòng mỗi ngày
  - Đánh dấu "Hôm nay" với viền màu
- Dữ liệu được lưu tự động sau mỗi session hoàn thành

### 🎨 4 App Themes (Giao diện tổng thể)
- **Light Pastel** - Giao diện sáng pastel
- **Dark Neon** - Giao diện tối neon
- **Galaxy** - Giao diện thiên hà
- **Campus** - Giao diện học đường

### 💾 Lưu Trữ Dữ Liệu
- Tất cả dữ liệu được lưu local với `SharedPreferences`
- **Dữ liệu được lưu:**
  - Theme tùy chỉnh
  - Session hiện tại (mỗi giây khi đang chạy)
  - Thống kê học tập (sau mỗi session hoàn thành)
  - Lịch sử chi tiết từng ngày
  - Streak và records
- Dữ liệu không mất khi tắt app
- Production-ready (không có mock/test data)

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
