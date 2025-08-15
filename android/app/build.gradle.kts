import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load secrets from android/key.properties (not committed to git)
val keystoreProperties = Properties().apply {
    val propsFile: File = rootProject.file("key.properties") // android/key.properties
    if (propsFile.exists()) {
        propsFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.example.zone_pilot"
    compileSdk = flutter.compileSdkVersion

    // UPDATED: Set the specific NDK version required by the plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.zone_pilot"
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Expose Google Maps key to Manifest via generated string resource
        // If key.properties is missing, this falls back to empty string.
        resValue(
            "string",
            "google_maps_key",
            (keystoreProperties["MAPS_API_KEY"] as? String) ?: ""
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
