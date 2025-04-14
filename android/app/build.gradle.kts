import java.util.Properties

// Read local.properties
val localProperties = Properties().apply {
    val propertiesFile = rootProject.file("local.properties")
    if (propertiesFile.exists()) {
        load(propertiesFile.inputStream())
    }
}

// Helper function to get property with fallback
fun getPropertyOrDefault(propertyName: String, defaultValue: String): String {
    return localProperties.getProperty(propertyName) ?: defaultValue
}

fun getPropertyOrDefaultInt(propertyName: String, defaultValue: Int): Int {
    return (localProperties.getProperty(propertyName) ?: defaultValue.toString()).toInt()
}

// Version management
val kotlinVersion = "1.9.22"
val gradleVersion = "8.2.2"
val coreKtxVersion = "1.12.0"
val multidexVersion = "2.0.1"
val desugarVersion = "2.1.4"
val androidxCoreVersion = "1.12.0"
val androidxAppcompatVersion = "1.6.1"

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.powersystemsacademy"
    
    // Updated to SDK 35 as recommended
    compileSdk = 35
    
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.powersystemsacademy"
        // Also update minSdk and targetSdk to be compatible
        minSdk = 21
        targetSdk = 35
        versionCode = getPropertyOrDefaultInt("flutter.versionCode", 1)
        versionName = getPropertyOrDefault("flutter.versionName", "1.0.0")
        
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:$desugarVersion")
    
    implementation("org.jetbrains.kotlin:kotlin-stdlib:$kotlinVersion")
    implementation("androidx.core:core-ktx:$coreKtxVersion")
    implementation("androidx.core:core:$androidxCoreVersion")
    implementation("androidx.appcompat:appcompat:$androidxAppcompatVersion")
    implementation("androidx.multidex:multidex:$multidexVersion")
}

// Configure Flutter Gradle Plugin
flutter {
    source = "../.."
}