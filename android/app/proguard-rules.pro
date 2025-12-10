# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }
-dontwarn io.flutter.**
-dontwarn androidx.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Keep audio player classes
-keep class xyz.luan.audioplayers.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }

# Keep workmanager classes
-keep class be.tramckrijte.workmanager.** { *; }

# Keep shared preferences
-keep class android.content.SharedPreferences { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
