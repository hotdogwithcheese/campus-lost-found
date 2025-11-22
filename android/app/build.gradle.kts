import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.campus_lost_found"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.campus_lost_found"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val releaseSigning = signingConfigs.create("release") {
        // Default: do nothing. Assign in buildType below.
    }

    buildTypes {
        getByName("release") {
            // Try to load key.properties, fallback to debug signing
            val keyFile = rootProject.file("key.properties")
            if (keyFile.exists()) {
                val props = Properties()
                props.load(FileInputStream(keyFile))
                val storePath = props.getProperty("storeFile")
                if (storePath != null && rootProject.file(storePath).exists()) {
                    releaseSigning.apply {
                        keyAlias = props.getProperty("keyAlias")
                        keyPassword = props.getProperty("keyPassword")
                        storeFile = rootProject.file(storePath)
                        storePassword = props.getProperty("storePassword")
                    }
                    signingConfig = releaseSigning
                    println("Release keystore loaded successfully!")
                } else {
                    println("Keystore not found. Using debug signing.")
                    signingConfig = signingConfigs.getByName("debug")
                }
            } else {
                println("key.properties not found. Using debug signing.")
                signingConfig = signingConfigs.getByName("debug")
            }

            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
