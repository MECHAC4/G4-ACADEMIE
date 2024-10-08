# Empêcher ProGuard d'obscurcir les classes Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Empêcher ProGuard d'obscurcir les classes Firebase (si tu utilises Firebase)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Garder les classes de modèles (si tu as des classes importantes que tu ne veux pas obscurcir)
-keep class com.example.monapp.models.** { *; }

# Empêcher l'obscurcissement des méthodes annotées avec @Keep (utile pour Retrofit ou Gson)
-keep @interface androidx.annotation.Keep
-keep class * {
    @androidx.annotation.Keep <methods>;
}

# Si tu utilises des services Google Play
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Évite les erreurs sur la réflexion (Reflection)
-keep class sun.misc.Unsafe { *; }
