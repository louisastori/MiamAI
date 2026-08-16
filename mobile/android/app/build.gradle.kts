import org.gradle.api.GradleException
import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = listOf(
    project.file("../key.properties"),
    rootProject.file("key.properties")
).distinctBy { it.absolutePath }.firstOrNull { it.exists() }
keystorePropertiesFile?.inputStream()?.use { keystoreProperties.load(it) }

fun signingProperty(propertyName: String, environmentName: String): String? {
    return (keystoreProperties.getProperty(propertyName) ?: System.getenv(environmentName))
        ?.takeIf { it.isNotBlank() }
}

fun resolveStoreFile(path: String): File {
    val candidate = File(path)
    return if (candidate.isAbsolute) {
        candidate
    } else {
        File(keystorePropertiesFile?.parentFile ?: rootProject.projectDir, path)
    }
}

val releaseStoreFile = signingProperty("storeFile", "MIAMAI_ANDROID_KEYSTORE_PATH")
val releaseStorePassword = signingProperty("storePassword", "MIAMAI_ANDROID_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingProperty("keyAlias", "MIAMAI_ANDROID_KEY_ALIAS")
val releaseKeyPassword = signingProperty("keyPassword", "MIAMAI_ANDROID_KEY_PASSWORD")
val releaseStoreFileResolved = releaseStoreFile?.let(::resolveStoreFile)
val releaseSigningConfigured = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword
).all { !it.isNullOrBlank() } && releaseStoreFileResolved?.exists() == true

gradle.taskGraph.whenReady {
    val needsReleaseSigning = allTasks.any {
        it.path.equals(":app:assembleRelease", ignoreCase = true) ||
            it.path.equals(":app:bundleRelease", ignoreCase = true)
    }
    if (needsReleaseSigning && !releaseSigningConfigured) {
        throw GradleException("La signature Android release n'est pas configuree. Renseigner mobile/android/key.properties ou les variables MIAMAI_ANDROID_*.")
    }
}

android {
    namespace = "fr.miamai.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "fr.miamai.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseSigningConfigured) {
                storeFile = releaseStoreFileResolved
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
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
