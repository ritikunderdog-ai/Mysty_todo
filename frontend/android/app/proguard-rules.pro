# Keep Isar classes and native JNI methods
-keep class dev.isar.** { *; }
-keepclassmembers class dev.isar.** { *; }
-dontwarn dev.isar.**

# Keep app models
-keep class com.example.mysty.models.** { *; }
-keepclassmembers class com.example.mysty.models.** { *; }

# Keep Flutter engine and plugins
-keep class io.flutter.** { *; }
-keepclassmembers class io.flutter.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.google.android.play.core.**
