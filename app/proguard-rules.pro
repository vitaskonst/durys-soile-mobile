# Gson maps JSON onto these by field name, so they must keep their names.
-keep class kz.nu.duryssoile.data.** { *; }

# Gson generic type tokens.
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# OkHttp/Retrofit ship their own consumer rules; these cover the stragglers.
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
