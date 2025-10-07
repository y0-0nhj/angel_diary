import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 파일 상단에 key.properties 파일을 읽는 함수 추가
fun getProperty(key: String, file: java.io.File): String {
    if (!file.exists()) {
        println("Missing file: ${file.absolutePath}. Create one at the project root for local development.")
        return ""
    }
    val properties = Properties()
    properties.load(FileInputStream(file))
    return properties.getProperty(key) ?: ""
}

android {
    namespace = "com.cosmonian.angeldiary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.cosmonian.angeldiary"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") { // release 서명 설정
            val keystoreFile = rootProject.file(getProperty("storeFile", rootProject.file("key.properties")))
            if (keystoreFile.exists()) {
                storeFile = keystoreFile
                storePassword = getProperty("storePassword", rootProject.file("key.properties"))
                keyAlias = getProperty("keyAlias", rootProject.file("key.properties"))
                keyPassword = getProperty("keyPassword", rootProject.file("key.properties"))
            } else {
                println("Release keystore file not found at ${keystoreFile.absolutePath}. Please create it and configure key.properties.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") // release 빌드 시 위에서 정의한 release 서명 사용
            isMinifyEnabled = false
            isShrinkResources = false // 리소스 축소 비활성화
            // proguardFiles 제거 - isMinifyEnabled가 false일 때는 불필요
        }
        debug {
            // debug 빌드 설정 (보통 signingConfig를 따로 명시하지 않음)
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ... (다른 의존성들)

    // 이 줄을 추가해줘!
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}