# 🍅 Pomodoro Study Timer

Ứng dụng Pomodoro Timer toàn diện dành cho việc học tập, được xây dựng bằng Flutter với đầy đủ tính năng quản lý thời gian, nhiệm vụ, mục tiêu, thống kê chi tiết và hệ thống thành tựu động viên.

## ✨ Tính năng Chính

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
  - Trạng thái HỌC/NGHỈ với màu sắc phân biệt
  - Đồng hồ đếm ngược lớn ở giữa vòng tròn
  - Dual progress bars hiển thị tiến độ học và nghỉ (%)
- **Vòng tròn tiến độ:**
  - Vòng ngoài (cam): Tiến độ học
  - Vòng trong (xanh): Tiến độ nghỉ
- **Điều khiển timer:**
  - Chọn số vòng (1-4 vòng) với hiển thị tổng thời gian
  - Bắt đầu/Tạm dừng/Tiếp tục
  - Reset phiên học
  - Dừng nhạc nền khi tạm dừng, phát lại khi tiếp tục
- **Tự động:**
  - Chuyển đổi từ học sang nghỉ
  - Chuyển từ nghỉ sang vòng học mới
  - Hoàn thành khi đủ số vòng đã chọn
- **Chế độ Focus Mode:**
  - Toàn màn hình không bị phân tâm
  - Chặn thoát ngoài ý muốn khi đang học
- Lưu trạng thái real-time khi đang chạy

### 📝 Quản lý Nhiệm vụ (Tasks)
- **Tạo nhiệm vụ học tập:**
  - Tiêu đề nhiệm vụ
  - Mô tả chi tiết (tùy chọn)
  - Thời gian ước tính (số Pomodoro)
  - Mức độ ưu tiên (Thấp/Trung bình/Cao)
- **Gắn task vào timer:**
  - Chọn task trước khi bắt đầu học
  - Tự động tính số Pomodoro đã hoàn thành cho task
  - Tự động hỏi hoàn thành task khi đạt đủ số Pomodoro ước tính
- **Quản lý task:**
  - Đánh dấu hoàn thành/chưa hoàn thành
  - Chỉnh sửa thông tin task
  - Xóa task (đơn lẻ hoặc chọn nhiều)
  - Lọc theo trạng thái: Tất cả/Chưa hoàn thành/Đã hoàn thành
- **Thống kê task:**
  - Hiển thị tổng số Pomodoro đã làm cho mỗi task
  - Hiển thị thời gian học tích lũy

### 🎯 Mục tiêu (Goals)
- **Tạo mục tiêu học tập:**
  - Tiêu đề mục tiêu
  - Mô tả chi tiết
  - Loại mục tiêu: Pomodoro hoặc Thời gian (phút)
  - Giá trị mục tiêu
  - Khung thời gian: Hàng ngày/Hàng tuần/Hàng tháng
  - Icon tùy chỉnh (emoji)
  - Màu sắc đại diện
- **Theo dõi tiến độ:**
  - Progress bar hiển thị % hoàn thành
  - Cập nhật tự động theo dữ liệu thống kê
  - Hiển thị giá trị hiện tại / mục tiêu
- **Quản lý mục tiêu:**
  - Chỉnh sửa mục tiêu
  - Xóa mục tiêu (đơn lẻ hoặc chọn nhiều)
  - Sắp xếp theo tiến độ hoặc thời gian tạo
- **Khung thời gian linh hoạt:**
  - Daily: Reset mỗi ngày mới
  - Weekly: Reset mỗi đầu tuần (Thứ 2)
  - Monthly: Reset mỗi đầu tháng

### 🏆 Hệ thống Thành tựu (Achievements)
- **Danh sách huy hiệu đa dạng:**
  - **Pomodoro:** 1, 10, 50, 100, 500 vòng hoàn thành
  - **Streak:** 3, 7, 14, 30 ngày học liên tục
  - **Thời gian:** 100, 500, 1000 phút học tập
  - **Đặc biệt:** Học sáng sớm, học đêm muộn, chiến binh cuối tuần
- **Trạng thái huy hiệu:**
  - Chưa mở: Icon xám mờ
  - Đã mở: Icon vàng gold sáng với hiệu ứng phát sáng
- **Theo dõi tiến độ:**
  - Progress bar cho từng achievement
  - Hiển thị giá trị hiện tại / yêu cầu
- **Phân loại theo category:**
  - Pomodoro
  - Streak
  - Thời gian
  - Đặc biệt
- Tự động unlock khi đạt mốc

### 🎨 Hoạt động Giải lao (Break Activities)
- **Gợi ý hoạt động thông minh:**
  - Tự động đề xuất 4 hoạt động (mỗi loại 1) khi bắt đầu nghỉ
  - Timer tạm dừng để chờ người dùng chọn
  - Sau khi chọn, timer đếm ngược theo thời gian của hoạt động
- **4 loại hoạt động:**
  - 🏃 **Vận động:** Đi bộ, kéo dài cơ, tập thể dục nhẹ
  - 🧘 **Thư giãn:** Thiền, hít thở sâu, nghe nhạc
  - 👥 **Xã hội:** Trò chuyện, gọi điện, nhắn tin
  - 🎨 **Sáng tạo:** Vẽ, viết nhật ký, chơi nhạc cụ
- **Quản lý hoạt động:**
  - Thêm hoạt động tùy chỉnh
  - Chỉnh sửa hoạt động
  - Xóa hoạt động (không thể xóa hoạt động mặc định)
  - Chọn thời gian hoạt động (1-30 phút)
- **Lịch sử sử dụng:**
  - Ghi nhận hoạt động đã chọn
  - Tránh gợi ý lại hoạt động vừa làm
- **Tùy chọn "Nghỉ bình thường":**
  - Bỏ qua chọn hoạt động
  - Sử dụng thời gian nghỉ mặc định của theme

### 🔔 Thông Báo & Âm Thanh
- **Âm thanh ting (volume 100%) + rung điện thoại** cho:
  - Bắt đầu học
  - Hoàn thành vòng học
  - Bắt đầu nghỉ
  - Hoàn thành vòng nghỉ
  - Hoàn thành toàn bộ chu kỳ
- **8 bản nhạc nền thư giãn ngẫu nhiên:**
  - Breezy Escape
  - Calming Rain
  - Chill Lofi Beat
  - Christmas Lofi
  - Days of Serenity
  - Lofi Chill
  - Morning Coffee Aroma
  - Peace in Every Note
- **Điều khiển nhạc nền:**
  - Phát tự động khi bắt đầu học
  - Dừng tự động khi kết thúc học hoặc tạm dừng
  - Fade in/out mượt mà
  - Volume 30% để không át tiếng thông báo
  - Tự động chuyển bài khi hết
- **Thông báo hệ thống:**
  - Thông báo nổi ở đầu màn hình
  - Thông báo push khi app ở background

### 📊 Thống kê Học Tập Chi Tiết
- **Tabs thống kê:**
  - **Hôm nay:** Thống kê chi tiết trong ngày
  - **Tuần này:** Biểu đồ cột 7 ngày
  - **Tháng này:** Biểu đồ xu hướng 30 ngày
- **Thống kê hôm nay:**
  - Tổng thời gian học (phút)
  - Số vòng Pomodoro hoàn thành
  - Thời gian trung bình mỗi session
  - Số session đã hoàn thành
- **Tổng quan toàn bộ:**
  - Tổng thời gian học tích lũy
  - Tổng số vòng Pomodoro
  - Kỷ lục Pomodoro trong 1 ngày
- **Chuỗi ngày học (Streak):**
  - Current streak: Số ngày học liên tục hiện tại
  - Longest streak: Kỷ lục cá nhân
  - Hiển thị với icon lửa 🔥 động
- **Biểu đồ trực quan:**
  - Biểu đồ cột theo tuần (FL Chart)
  - Biểu đồ đường theo tháng
  - Màu sắc theo theme
- **Lịch sử chi tiết:**
  - Danh sách 30 ngày gần nhất
  - Thời gian học và số vòng mỗi ngày
  - Số session mỗi ngày
  - Đánh dấu "Hôm nay"
- Dữ liệu cập nhật real-time sau mỗi session

### 🎨 4 App Themes (Giao diện tổng thể)
- **Light Pastel** - Giao diện sáng pastel
- **Dark Neon** - Giao diện tối neon
- **Galaxy** - Giao diện thiên hà
- **Campus** - Giao diện học đường

### � Home Screen Widget (Android)
- **Hiển thị trên màn hình chính:**
  - Timer đếm ngược real-time
  - Trạng thái: HỌC/NGHỈ
  - Tên theme đang dùng
  - Tên task hiện tại (nếu có)
  - Tiến độ %
- **Thống kê nhanh:**
  - Pomodoro hôm nay
  - Thời gian học hôm nay
  - Streak hiện tại
- **Tương tác từ widget:**
  - Nhấn để mở app
  - Cập nhật tự động khi timer chạy
- Hỗ trợ nhiều kích thước widget

### 💾 Lưu Trữ Dữ Liệu
- **Lưu trữ local với SharedPreferences:**
  - Theme tùy chỉnh
  - Session hiện tại (real-time mỗi giây)
  - Tasks và trạng thái hoàn thành
  - Goals và tiến độ
  - Achievements và unlock status
  - Break activities tùy chỉnh
  - Lịch sử break activities
  - Thống kê học tập chi tiết
  - Lịch sử từng ngày
  - Streak và records
- **Tính năng:**
  - Tự động lưu khi có thay đổi
  - Không mất dữ liệu khi tắt app
  - Khôi phục session khi restart app
  - Production-ready (không có test data)

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

### Android App Bundle (AAB) - For Google Play Store
```bash
flutter build appbundle --release --no-tree-shake-icons
```

> **Note:** Flag `--no-tree-shake-icons` được sử dụng vì app có dynamic IconData trong break activities.

File output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## 📁 Cấu Trúc Project

```
lib/
├── main.dart                           # Entry point & Provider setup
├── models/                             # Data models
│   ├── achievement.dart                # Achievement model
│   ├── app_theme.dart                  # App theme model
│   ├── break_activity.dart             # Break activity model
│   ├── goal.dart                       # Goal model
│   ├── pomodoro_session.dart           # Session model
│   ├── study_statistics.dart           # Statistics model
│   ├── study_theme.dart                # Study theme model
│   └── task.dart                       # Task model
├── providers/                          # State management (Provider)
│   ├── achievement_provider.dart       # Achievements state
│   ├── app_theme_provider.dart         # App theme state
│   ├── break_activities_provider.dart  # Break activities state
│   ├── goal_provider.dart              # Goals state
│   ├── statistics_provider.dart        # Statistics state
│   ├── task_provider.dart              # Tasks state
│   ├── theme_provider.dart             # Study themes state
│   └── timer_provider.dart             # Timer state
├── screens/                            # UI screens
│   ├── achievements_screen.dart        # Achievements list
│   ├── break_activities_screen.dart    # Break activities management
│   ├── focus_mode_screen.dart          # Fullscreen focus timer
│   ├── goals_screen.dart               # Goals management
│   ├── statistics_screen.dart          # Statistics with charts
│   ├── tasks_screen.dart               # Tasks management
│   ├── theme_selection_screen.dart     # Theme picker
│   ├── timer_screen.dart               # Main timer screen
│   └── widget_settings_screen.dart     # Widget configuration
├── services/                           # Services
│   ├── audio_service.dart              # Audio & music playback
│   ├── notification_service.dart       # Push notifications
│   └── widget_service.dart             # Home screen widget
└── widgets/                            # Reusable widgets
    ├── circular_timer_painter.dart     # Custom circular progress
    ├── timer_controls.dart             # Play/Pause/Reset buttons
    └── timer_display.dart              # Timer countdown display
```

## 🛠️ Dependencies

### Core
- `provider` ^6.1.2: State management
- `shared_preferences` ^2.3.3: Local data storage
- `uuid` ^4.5.1: Unique ID generation
- `intl` ^0.19.0: Date formatting & localization (Vietnamese)

### UI & Visualization
- `fl_chart` ^0.66.2: Charts & graphs
- `flutter_launcher_icons` ^0.13.1: App icons

### Media & Notifications
- `audioplayers` ^5.2.1: Background music & sound effects
- `flutter_local_notifications` ^17.2.4: Push notifications
- `vibration` ^2.1.0: Haptic feedback

### Platform Integration
- `home_widget` ^0.6.0: Android home screen widget
- `device_info_plus` ^11.5.0: Device information

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
