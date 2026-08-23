# Preserve generic signatures and attributes for Gson / TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Gson rules
-keep class com.google.gson.** { *; }
-keepclassmembers class * implements com.google.gson.TypeAdapter { *; }
-keepclassmembers class * implements com.google.gson.TypeAdapterFactory { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.android.gms.** { *; }

# Timezone
-keep class com.bluefirebuilding.flutter_timezone.** { *; }

