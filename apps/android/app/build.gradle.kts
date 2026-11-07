import org.gradle.api.tasks.Exec
import org.gradle.api.tasks.Sync

plugins {
    id("com.android.application")
}

val repoRoot = rootProject.projectDir.resolve("../..")
val webDist = repoRoot.resolve("apps/web/dist")
val packagedGame = layout.projectDirectory.dir("src/main/assets/game")

android {
    namespace = "io.adambailey.roundgarden"
    compileSdk {
        version = release(37) {
            minorApiLevel = 2
        }
    }

    defaultConfig {
        applicationId = "io.adambailey.roundgarden"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}

dependencies {
    implementation("androidx.webkit:webkit:1.18.0")
}

val buildWebGame by tasks.registering(Exec::class) {
    workingDir = repoRoot
    commandLine("npm", "run", "build", "--workspace", "@roundgarden/web")
    environment("ROUNDGARDEN_ANDROID_BUILD", "true")
    inputs.files(
        repoRoot.resolve("apps/web/src"),
        repoRoot.resolve("apps/web/index.html"),
        repoRoot.resolve("apps/web/vite.config.js"),
        repoRoot.resolve("apps/web/package.json"),
    )
    outputs.dir(webDist)
}

val packageWebGame by tasks.registering(Sync::class) {
    dependsOn(buildWebGame)
    from(webDist) {
        exclude("privacy.html", "support.html")
    }
    into(packagedGame)
}

tasks.named("preBuild") {
    dependsOn(packageWebGame)
}
