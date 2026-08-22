import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.reader().use { reader -> keystoreProperties.load(reader) }
}

fun releaseKeystoreReady(): Boolean {
    val storeFileName = keystoreProperties.getProperty("storeFile") ?: return false
    return !keystoreProperties.getProperty("keyAlias").isNullOrBlank() &&
        !keystoreProperties.getProperty("keyPassword").isNullOrBlank() &&
        !keystoreProperties.getProperty("storePassword").isNullOrBlank() &&
        rootProject.file(storeFileName).isFile
}

android {
    namespace = "app.dhammapath.dhamma_path"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // Base application ID — overridden per flavour below (PRD/Architecture
        // §15: dev = app.dhammapath.dev, prod = app.dhammapath).
        applicationId = "app.dhammapath"
        minSdk = 26 // Android 8.0 — PRD §3.1 device assumptions
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "app.dhammapath.dev"
            resValue(type = "string", name = "app_name", value = "Dhamma Path Dev")
        }
        create("prod") {
            dimension = "env"
            applicationId = "app.dhammapath"
            resValue(type = "string", name = "app_name", value = "Dhamma Path")
        }
    }

    signingConfigs {
        if (releaseKeystoreReady()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile")!!)
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeystoreReady()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Prod Play uploads must not silently fall back to the debug key.
gradle.taskGraph.whenReady {
    val needsUploadKey = allTasks.any { it.name.contains("ProdRelease") }
    if (needsUploadKey && !releaseKeystoreReady()) {
        throw GradleException(
            "Prod release requires apps/mobile/android/key.properties and the upload keystore. " +
                "Copy key.properties.example to key.properties and generate upload-keystore.jks.",
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
