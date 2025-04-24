plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.chagall04.claritybreak.clarity_break" // Ensure this matches your actual package name
    compileSdk = flutter.compileSdkVersion

    // *** FIX 1: Set specific NDK version required by plugins ***
    ndkVersion = "27.0.12077973" // Changed from flutter.ndkVersion

    compileOptions {
        // You are targeting Java 11, which is fine.
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // *** FIX 2: Enable Core Library Desugaring ***
        isCoreLibraryDesugaringEnabled = true // Added this line
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Specify your own unique Application ID
        applicationId = "com.chagall04.claritybreak.clarity_break" // Ensure this matches your actual package name
        // You can update the following values to match your application needs.
        minSdk = flutter.minSdkVersion // Ensure this is appropriate (often 21 or higher)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // multiDexEnabled = true // Consider uncommenting if you hit multidex issues on older Android APIs (below 21)
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // It's good practice to ensure Kotlin sources are included
    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }
}

flutter {
    source = "../.."
}

// *** FIX 3: Add dependency block if missing and include desugaring library ***
dependencies {
    // Add the core library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Other standard dependencies that might be needed explicitly (sometimes Flutter handles them)
    // implementation("androidx.core:core-ktx:+")
    // implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version") // Use jdk8 if targeting Java 8 features via desugaring

    // Add any other specific Android dependencies your project might need here
}