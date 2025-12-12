import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), timerState: "idle", remainingTime: 1500, sessionType: "study", themeName: "Classic", taskName: "", todayPomodoros: 0, todayMinutes: 0, currentStreak: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), timerState: "idle", remainingTime: 1500, sessionType: "study", themeName: "Classic", taskName: "", todayPomodoros: 0, todayMinutes: 0, currentStreak: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.pomodoro.study")
        
        let timerState = userDefaults?.string(forKey: "timer_state") ?? "idle"
        let remainingTime = userDefaults?.integer(forKey: "remaining_time") ?? 1500
        let sessionType = userDefaults?.string(forKey: "session_type") ?? "study"
        let themeName = userDefaults?.string(forKey: "theme_name") ?? "Classic"
        let taskName = userDefaults?.string(forKey: "task_name") ?? ""
        let todayPomodoros = userDefaults?.integer(forKey: "today_pomodoros") ?? 0
        let todayMinutes = userDefaults?.integer(forKey: "today_minutes") ?? 0
        let currentStreak = userDefaults?.integer(forKey: "current_streak") ?? 0
        
        let entry = SimpleEntry(
            date: Date(),
            timerState: timerState,
            remainingTime: remainingTime,
            sessionType: sessionType,
            themeName: themeName,
            taskName: taskName,
            todayPomodoros: todayPomodoros,
            todayMinutes: todayMinutes,
            currentStreak: currentStreak
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let timerState: String
    let remainingTime: Int
    let sessionType: String
    let themeName: String
    let taskName: String
    let todayPomodoros: Int
    let todayMinutes: Int
    let currentStreak: Int
}

struct PomodoroWidgetEntryView : View {
    var entry: Provider.Entry
    
    var timeText: String {
        let minutes = entry.remainingTime / 60
        let seconds = entry.remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var sessionTypeText: String {
        entry.sessionType == "study" ? "Học tập" : "Nghỉ giải lao"
    }
    
    var timeColor: Color {
        if entry.timerState == "idle" {
            return Color.gray
        }
        return entry.sessionType == "study" ? Color.green : Color.blue
    }

    var body: some View {
        VStack(spacing: 8) {
            // Header
            Text("Pomodoro Study")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.11, green: 0.37, blue: 0.13))
            
            Spacer()
            
            // Timer
            Text(timeText)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(timeColor)
            
            // Session Type
            Text(sessionTypeText)
                .font(.system(size: 12))
                .foregroundColor(timeColor.opacity(0.8))
            
            // Theme Name
            Text(entry.themeName)
                .font(.system(size: 10))
                .foregroundColor(Color.gray)
            
            Spacer()
            
            // Statistics
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("\(entry.todayPomodoros)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.orange)
                    Text("Hôm nay")
                        .font(.system(size: 8))
                        .foregroundColor(Color.gray)
                }
                
                VStack(spacing: 2) {
                    Text("\(entry.currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.pink)
                    Text("Streak")
                        .font(.system(size: 8))
                        .foregroundColor(Color.gray)
                }
                
                VStack(spacing: 2) {
                    Text("\(entry.todayMinutes)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.blue)
                    Text("Phút")
                        .font(.system(size: 8))
                        .foregroundColor(Color.gray)
                }
            }
            
            // Task Name (if any)
            if !entry.taskName.isEmpty {
                Text("📝 \(entry.taskName)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

@main
struct PomodoroWidget: Widget {
    let kind: String = "PomodoroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PomodoroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pomodoro Timer")
        .description("Hiển thị timer và thống kê học tập")
        .supportedFamilies([.systemMedium])
    }
}

struct PomodoroWidget_Previews: PreviewProvider {
    static var previews: some View {
        PomodoroWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            timerState: "running",
            remainingTime: 1500,
            sessionType: "study",
            themeName: "Classic",
            taskName: "Học toán",
            todayPomodoros: 5,
            todayMinutes: 125,
            currentStreak: 3
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
